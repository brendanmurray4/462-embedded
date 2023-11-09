/*
 * sdCard.h
 *
 *  Created on: Mar. 16, 2022
 *      Author: anita
 */

#ifndef SRC_SDCARD_H_
#define SRC_SDCARD_H_

#include <xil_types.h>
#include "ff.h"
#include "xil_printf.h"
#include <xstatus.h>
#include "xil_cache.h"

int SD_Init();
int SD_Eject();
int ReadFile(char *FileName, u32 DestinationAddress, int size);
int WriteFile(char *FileName, u32 size, u32 SourceAddress);
int readHeader(char *FileName, void* header, FIL* fil);


#endif /* SRC_SDCARD_H_ */
