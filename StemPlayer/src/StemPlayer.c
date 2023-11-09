//This program was written by Brendan Murray for ENSC 462 Final Project: Zedboard Stem Player
#include "ff.h"
#include "xstatus.h"
#include <stdlib.h>
#include "xil_printf.h"
#include "xil_cache.h"
#include "platform_config.h"
#include "platform.h"
#include "sdCard.h"
#include <stdio.h>
#include <sleep.h>
//#include "myIIC.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "xgpio.h"


//--------------------SD CARD VARIABLES-----------------------------
FATFS fatfs;
XGpio gpio;
char filename[10] = "1.wav";
struct Header{
	//Struct derived from http://truelogic.org/wordpress/2015/09/04/parsing-a-wav-file-in-c/
	unsigned char ID[4]; //RIFF String
	unsigned int size; //Total file size in bytes
	unsigned char format[4];// WAVE string
	unsigned char fmt_chunk_marker[4];//"fmt" string
	unsigned int fmt_size; //Length of format
	unsigned short format_type; //format type
	unsigned short channels; //no. of channels
	unsigned int sample_rate; //sample rate
	unsigned int byterate; // SampleRate * numChannels * BitsPerSample/8
	unsigned short block_align; //NumChannels*BitsPerSample/8
	unsigned short bits_per_sample; //Bits per sample
	unsigned char data_chunk_header[4]; //"data" chunk header
	unsigned int data_size; //Size of next data chunk
};

//-----------------DMA TRANSFER VARIABLES-----------------------------
/* Instance of the XAxiDma */
static XAxiDma AxiDma;
#define DMA_DEV_ID		XPAR_AXIDMA_0_DEVICE_ID

#ifdef XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR		XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#elif defined (XPAR_MIG7SERIES_0_BASEADDR)
#define DDR_BASE_ADDR	XPAR_MIG7SERIES_0_BASEADDR
#elif defined (XPAR_MIG_0_BASEADDR)
#define DDR_BASE_ADDR	XPAR_MIG_0_BASEADDR
#elif defined (XPAR_PSU_DDR_0_S_AXI_BASEADDR)
#define DDR_BASE_ADDR	XPAR_PSU_DDR_0_S_AXI_BASEADDR
#endif

#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
		 DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR		0x01000000
#else
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x1000000)
#endif

#define TX_BUFFER_BASE		(MEM_BASE_ADDR + 0x00100000)
#define RX_BUFFER_BASE		(MEM_BASE_ADDR + 0x00300000)
#define RX_BUFFER_HIGH		(MEM_BASE_ADDR + 0x004FFFFF)

#define MAX_PKT_LEN		0x20

#define TEST_START_VALUE	0xC

#define NUMBER_OF_TRANSFERS	10
/* Instance of the Interrupt Controller */

void gpioInit(){
	int status;
	status = XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_DEVICE_ID);
	if(status != XST_FAILURE){
		return XST_SUCCESS;
	}
}

int main(){
	FIL fil;
	FRESULT rc;
	short br1, br2;
	struct Header WAVHeader;
	int numTransfers;
	// Setup UART for debugging
	init_platform();
	gpioInit();

	xil_printf("\n\nstarting\n");

//------------------------SETTING AUDIO REGISTERS-----------------------------------

	xil_printf("\n\n SETTING AUDIO REGISTERS\n");
	//setAudioRegisters();
	//-------------------------BEGIN READING FROM SD CARD----------------------


    xil_printf("\n\n BEGIN READING FROM SD CARD\n");
    //MOUNT FILE SYSTEM
	int SDStatus = SD_Init(&fatfs);
	if (SDStatus != XST_SUCCESS) {
		print("file system init failed\n\r");
		return XST_FAILURE;
	}

	//READ HEADER AND DETERMINE INFORMATION
	readHeader(filename, (void*)&WAVHeader, &fil);
	if( (WAVHeader.size - 36) % 64 == 0){
		numTransfers = (WAVHeader.size -36) / 64;
	}
	else{
		numTransfers = ((WAVHeader.size -36) / 64) + 1;
	}


	//----------------------DMA TRANSFERRING------------------------------------------------
	int DMAStatus;
	XAxiDma_Config *Config;

	u8 *TXBufferPtr;
	u8 *RXBufferPtr;
	TXBufferPtr = (u8 *)TX_BUFFER_BASE ;
	RXBufferPtr = (u8 *)RX_BUFFER_BASE;
	/* Initialize the XAxiDma device.
	*/
	xil_printf("\r\nBEGINNING DMA TRANSFER\r\n");

	Config = XAxiDma_LookupConfig(DMA_DEV_ID);
	if (!Config) {
		xil_printf("No config found for %d\r\n", DMA_DEV_ID);

		return XST_FAILURE;
	}

	/* Initialize DMA engine */
	DMAStatus = XAxiDma_CfgInitialize(&AxiDma, Config);

	if (DMAStatus != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", DMAStatus);
		return XST_FAILURE;
	}

	if(XAxiDma_HasSg(&AxiDma)){
		xil_printf("Device configured as SG mode \r\n");
		return XST_FAILURE;
	}

	/* Disable interrupts, we use polling mode
		 */
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
						XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
						XAXIDMA_DMA_TO_DEVICE);


	/* Flush the buffer before the DMA transfer, in case the Data Cache
	 * is enabled
	 */
	Xil_DCacheFlushRange((UINTPTR)TXBufferPtr, MAX_PKT_LEN);
	rc = f_open(&fil, filename, FA_READ);
	// The main transfer loop
	for(int i = 0; i < numTransfers; i++)
	{
		br1 = 0;
		br2 = 0;
		SDStatus = f_read(&fil, TXBufferPtr, 32, (UINT*)&br1);
		if (SDStatus) {
			xil_printf(" ERROR : f_read returned %d\r\n", rc);
			return XST_FAILURE;
		}
		if(br1 == 32){
			SDStatus = f_read(&fil, TXBufferPtr+32, 32, (UINT*)&br2);
			if (SDStatus) {
				xil_printf(" ERROR : f_read returned %d\r\n", rc);
				return XST_FAILURE;
			}
		}
		Xil_DCacheFlushRange((UINTPTR)TXBufferPtr, MAX_PKT_LEN);
		DMAStatus = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) TXBufferPtr,
							br1+br2, XAXIDMA_DEVICE_TO_DMA);

		if (DMAStatus != XST_SUCCESS) {
			return XST_FAILURE;
		}
		DMAStatus = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) RXBufferPtr,
				br1+br2, XAXIDMA_DMA_TO_DEVICE);
		while ((XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA) ) ||
				(XAxiDma_Busy(&AxiDma,XAXIDMA_DMA_TO_DEVICE))) {
						/* Wait */
				}

		}

	xil_printf("\nFinished Transferring file\n");
	//-------------------------TYING UP LOOSE ENDS---------------------------------------

	SDStatus=SD_Eject(&fatfs);
    if (SDStatus != XST_SUCCESS) {
      	print("SD card unmount failed\n\r");
		return XST_FAILURE;
        }
	xil_printf("Done");
	return 0;
}

