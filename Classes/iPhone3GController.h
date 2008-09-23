//
//  iPhone3GController.h
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <stdio.h>
#define LAST_VERSION_MAJOR 1
#define LAST_VERSION_MINOR 0
#define VERSION_INTEGER	LAST_VERSION_MAJOR*10+LAST_VERSION_MINOR

#import "ChangedState.h"
#import "GPSController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface iPhone3GController : GPSController<CLLocationManagerDelegate> {
	CLLocationManager* locManager;
	NSTimeInterval lastTimeStamp;
}
- (id)initWithDelegate:(id)del;
@end
