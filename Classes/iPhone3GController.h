//
//  iPhone3GController.h
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "ChangedState.h"
#import "GPSController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#define SPEED_FILTER_LENGTH 5
@interface iPhone3GController : GPSController<CLLocationManagerDelegate> {
	CLLocationManager* locManager;
	NSTimeInterval lastTimeStamp;
	BOOL speedHasBeenUpdated;
	ChangedState* chMsg;
	BOOL haveSpeed;
	float speedFilter[SPEED_FILTER_LENGTH];
	float speedFilterWeight[SPEED_FILTER_LENGTH];
	int filterI;
}
- (id)initWithDelegate:(id)del;
@end
