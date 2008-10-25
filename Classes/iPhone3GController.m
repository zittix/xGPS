//
//  iPhone3GController.m
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "iPhone3GController.h"
#define USE_UI

@implementation iPhone3GController

- (BOOL)EnableGPS {
	
	if(locManager.locationServicesEnabled){
		speedHasBeenUpdated=NO;
	//	speedCheck=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkSpeed) userInfo:nil repeats:YES];
		[locManager startUpdatingLocation];
		isEnabled=YES;
	}
	return YES;
}
- (BOOL)DisableGPS {
	
	if(locManager.locationServicesEnabled){
		[locManager stopUpdatingLocation];
		//[speedCheck invalidate];
		speedCheck=nil;
		isEnabled=NO;
	}
	return YES;
}
-(NSString*)name {
	return @"iPhone 3G GPS";
}
-(void)checkSpeed {
	NSLog(@"Checking speed");
	if(!speedHasBeenUpdated) {
		NSLog(@"Wrong speed");
		gps_data.fix.speed=0.0;
#ifdef USE_UI
		[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:SPEED andParent:self] waitUntilDone:YES];
#else
		[delegate gpsChanged:[ChangedState objWithState:SPEED andParent:self]];
#endif
	}
	speedHasBeenUpdated=NO;
}
-(void) dealloc {
	[super dealloc];
	[locManager release];
	[chMsg release];
}
- (id)initWithDelegate:(id)del {
	self=[super initWithDelegate:del];
	locManager=[[CLLocationManager alloc] init];
	locManager.delegate=self;
	locManager.distanceFilter=kCLDistanceFilterNone;
	locManager.desiredAccuracy=kCLLocationAccuracyBest;
	version_minor=0;
	version_major=1;
	validLicense=YES;
	if(!locManager.locationServicesEnabled) {
		NSLog(@"Unable to use CoreLocation framework: Not enabled");
#ifdef USE_UI
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"xGPS Error",@"Error title") message:NSLocalizedString(@"The Location Services are not enabled on your device. Use the Settings application on your Home screen to fix this problem.",@"GPS iphone 3G error") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[alert show];
#endif
		return self;
	}
	isConnected=YES;
	chMsg=[[ChangedState objWithState:SPEED andParent:self] retain];
	return self;
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	switch(error.code) {
		case kCLErrorDenied: {
			isEnabled=NO;
			[locManager stopUpdatingLocation];
			[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:STATE_CHANGE andParent:self] waitUntilDone:YES];
		}break;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	//NSLog(@"SPeed: %f",[newLocation speed]);
	if(oldLocation!=nil) {
		CLLocationDistance dx=[newLocation getDistanceFrom:oldLocation];
		NSTimeInterval dt=[newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
		lastTimeStamp=oldLocation.timestamp.timeIntervalSince1970;
		if(dt>0.0f && dx>3.0f) {
			//NSLog(@"Available speed");
			
			double speed=dx/dt;
							
				gps_data.fix.speed=speed;
				speedHasBeenUpdated=YES;

			
			if(gps_data.fix.speed>60)
				gps_data.fix.speed=0.0;
		}else {
			gps_data.fix.speed=0.0;
		}
		
	}else {
		gps_data.fix.speed=0.0;
	}

	gps_data.fix.latitude=newLocation.coordinate.latitude;
	gps_data.fix.longitude=newLocation.coordinate.longitude;
	gps_data.fix.altitude=newLocation.altitude;
	chMsg.state=POS;

	[delegate gpsChanged:chMsg];
	chMsg.state=SPEED;
	[delegate gpsChanged:chMsg];

	
	//Update signal quality
	signalQuality=100;
	if(newLocation.verticalAccuracy<0) signalQuality-=40;
	if(newLocation.horizontalAccuracy<0) signalQuality-=90;
	
	if(newLocation.horizontalAccuracy==kCLLocationAccuracyNearestTenMeters) {
		signalQuality-=40;
	} else if(newLocation.horizontalAccuracy==kCLLocationAccuracyHundredMeters) {
		signalQuality-=70;
	} else if(newLocation.horizontalAccuracy==kCLLocationAccuracyKilometer) {
		signalQuality-=70;
	} else if(newLocation.horizontalAccuracy==kCLLocationAccuracyThreeKilometers) {
		signalQuality-=80;
	}
			
	if(signalQuality<0) signalQuality=0;

	chMsg.state=SIGNAL_QUALITY;
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
}
@end
