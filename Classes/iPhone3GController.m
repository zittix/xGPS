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
		[locManager startUpdatingLocation];
		isEnabled=YES;
	}
	return YES;
}
- (BOOL)DisableGPS {
	
	if(locManager.locationServicesEnabled){
		[locManager stopUpdatingLocation];
		isEnabled=NO;
	}
	return YES;
}
-(NSString*)name {
	return @"iPhone 3G GPS";
}
-(void) dealloc {
	[super dealloc];
	[locManager release];
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
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"xGPS Error",@"Error message title") message:NSLocalizedString(@"The Location Services are not enabled on your device. Use the Settings application on your Home screen to fix this problem.",@"GPS iphone 3G error") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Close button of message box") otherButtonTitles:nil];
		[alert show];
#endif
		return self;
	}
	isConnected=YES;
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
	if(oldLocation!=nil && lastTimeStamp!=oldLocation.timestamp.timeIntervalSince1970) {
		CLLocationDistance dx=[newLocation getDistanceFrom:oldLocation];
		NSTimeInterval dt=[newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
		if(dt>0.0f && dx>2.0f) {
			gps_data.fix.speed=dx/dt;
			if(gps_data.fix.speed>60)
				gps_data.fix.speed=0.0;
		}else
			gps_data.fix.speed=0.0;
		lastTimeStamp=oldLocation.timestamp.timeIntervalSince1970;
	}
	else
		gps_data.fix.speed=0.0;
	
	gps_data.fix.latitude=newLocation.coordinate.latitude;
	gps_data.fix.longitude=newLocation.coordinate.longitude;
	gps_data.fix.altitude=newLocation.altitude;
#ifdef USE_UI
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:POS andParent:self] waitUntilDone:YES];
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:SPEED andParent:self] waitUntilDone:YES];
#else
	[delegate gpsChanged:[ChangedState objWithState:POS andParent:self]];
	[delegate gpsChanged:[ChangedState objWithState:SPEED andParent:self]];
#endif
}
@end
