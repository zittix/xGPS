//
//  iGPSDController.h
//  xGPSUtil
//
//  Copyright 2008 Xwaves. All rights reserved.
//
#import <Foundation/Foundation.h>


#include <stdio.h>

#import "ChangedState.h"
#import "GPSController.h"


@interface iGPSDController : GPSController {

}

- (id)initWithDelegate:(id)del;
- (void) threadSerialGPS;
@end
