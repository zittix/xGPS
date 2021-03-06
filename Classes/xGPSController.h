//
//  xGPSController.h
//  xGPSUtil
//
//  Created by Mathieu on 8/5/08.
//  Copyright 2008 Xwaves. All rights reserved.
//
#import <Foundation/Foundation.h>


#include <stdio.h>
#define LAST_VERSION_MAJOR 1
#define LAST_VERSION_MINOR 0
#define VERSION_INTEGER	LAST_VERSION_MAJOR*10+LAST_VERSION_MINOR

#import "ChangedState.h"
#import "GPSController.h"


@interface xGPSController : GPSController {
	NSTimer* checkTimer;
	BOOL hasReceivedOK;
	BOOL firstStart;

	NSLock* lockReceivedOk;

}

- (BOOL)canUpdateFirmware;
- (BOOL)PutBootloaderMode;

- (id)initWithDelegate:(id)del;
- (void) threadSerialGPS;
@end
