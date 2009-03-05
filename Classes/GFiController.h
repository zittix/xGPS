//
//  G-FiController.h
//  G-Fi
//
//  Created by Steven Mattera on 12/9/08.
//  Copyright 2008 PosiMotion. All rights reserved.
//
//	This source code is the property of PosiMotion LLC. It is intended only for the 
//	person or entity to which it was sent to and may contain information that is 
//	privileged, confidential, or otherwise protected from disclosure. Distribution 
//	or copying of this source code, or the information contained herein, to anyone 
//	other than the intended recipient is prohibited, unless otherwise permitted by
//	PosiMotion LLC.
//
#import <Foundation/Foundation.h>
#import "ChangedState.h"
#import "GPSController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface GFiController : GPSController {
	CLLocation *currentGfiLocation;
	float currentHeading;
	float currentSpeed;
	NSString *strNMEA;
	NSTimer *timerNew;
	ChangedState* chMsg;
}

- (CLLocation *)parseNMEAData:(NSString *)data;
- (int)startUDPSocket;
- (NSString *)getData;
- (int)stopUDPSocket;

@end
