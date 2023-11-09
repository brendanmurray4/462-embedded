/*
 * sdCard.c
 *
 *  Created on: Mar. 16, 2022
 *      Author: anita
 */


#include "sdCard.h"

static FATFS  fatfs; //struct representing the Fat File System

int SD_Init() //mount the SD Card
{
	FRESULT rc;
	TCHAR *Path = "0:/";
	rc = f_mount(&fatfs,Path,0);
	if (rc) {
		xil_printf(" ERROR : f_mount returned %d\r\n", rc);
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

int SD_Eject() //unmount the SD Card
{
	FRESULT rc;
	TCHAR *Path = "0:/";
	rc = f_unmount(Path);
	if (rc) {
		xil_printf(" ERROR : f_mount returned %d\r\n", rc);
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

int readHeader(char *FileName, void* header, FIL* fil){
	FRESULT rc;
	UINT br;
	rc = f_open(fil, FileName, FA_READ);
	if (rc) {
		xil_printf(" ERROR : f_open returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_read(fil, header, 32, &br);
	if (rc) {
		xil_printf(" ERROR : f_read returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_read(fil,(char*)(header+32), 12, &br);
	if (rc) {
		xil_printf(" ERROR : f_read returned %d\r\n", rc);
		return XST_FAILURE;
	}
	Xil_DCacheFlush();
	return XST_SUCCESS;
}


//read 32b from the SD Card. Provide filename, read from address to EOF
int ReadFile(char *FileName, u32 DestinationAddress, int size)
{
	FIL fil;
	FRESULT rc;
	UINT br;
	rc = f_open(&fil, FileName, FA_READ);
	if (rc) {
		xil_printf(" ERROR : f_open returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_read(&fil, (void*) DestinationAddress, size, &br);
	if (rc) {
		xil_printf(" ERROR : f_read returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_close(&fil);
	if (rc) {
		xil_printf(" ERROR : f_close returned %d\r\n", rc);
		return XST_FAILURE;
	}
	Xil_DCacheFlush();
	return XST_SUCCESS;
}

int WriteFile(char *FileName, u32 size, u32 SourceAddress){
	UINT btw;
	static FIL fil; // File instance
	FRESULT rc; // FRESULT variable
	rc = f_open(&fil, (char *)FileName, FA_OPEN_ALWAYS | FA_WRITE); //f_open
	if (rc) {
		xil_printf(" ERROR : f_open returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_write(&fil,(const void*)SourceAddress,size,&btw);
	if (rc) {
		xil_printf(" ERROR : f_write returned %d\r\n", rc);
		return XST_FAILURE;
	}
	rc = f_close(&fil);
	if (rc) {
		xil_printf(" ERROR : f_write returned %d\r\n", rc);
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}
