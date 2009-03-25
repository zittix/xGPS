//
//  iPhone3GController.m
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "iPhone3GController.h"
#define USE_UI

@interface CLLocation (toIgnore2dot1FirmwareError)
-(double)speed;
@end

@implementation iPhone3GController

- (BOOL)EnableGPS {
	if(isEnabled) return NO;
	if(locManager.locationServicesEnabled){
		speedHasBeenUpdated=NO;
		[locManager startUpdatingLocation];
		isEnabled=YES;
		filterI=0;
	}
	return YES;
}
- (BOOL)DisableGPS {
	if(!isEnabled) return NO;
	memset(&gps_data,0,sizeof(struct gps_data_t));
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
	[locManager release];
	[chMsg release];
	[super dealloc];
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
	
	//Check if speed is supported
	isEnabled=NO;
	
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
-(BOOL) needSerial {
	return NO;
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	BOOL hasGPSSpeed=NO;
	
	if(![newLocation respondsToSelector:@selector(speed)]) {
		hasGPSSpeed=NO;
	} else {
		gps_data.fix.speed=[newLocation speed];
		if(gps_data.fix.speed<0) {
			gps_data.fix.speed=0;
			hasGPSSpeed=NO;
		}
	}
	
	
	
	if(!hasGPSSpeed) {
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
	}
	
	//Filter out speed
	
	//1. add the speed to the stack
	if(filterI<SPEED_FILTER_LENGTH) {
		speedFilter[filterI]=gps_data.fix.speed;
		
		filterI++;
	} else {
		for(int i=1;i<SPEED_FILTER_LENGTH;i++) {
			speedFilter[i-1]=speedFilter[i];
		}
		for(int i=1;i<SPEED_FILTER_LENGTH;i++) {
			speedFilterWeight[i-1]=speedFilterWeight[i];
		}
		speedFilter[filterI-1]=gps_data.fix.speed;
	}
	
	//2. Compute the weight of the added speed
	//The more diff there is between the last speed, the less is the weight
	if(filterI>1) {
		
		float diff=fabs(speedFilter[filterI-2]-speedFilter[filterI-1]);
		if(diff<1.0f) diff=1.0f;
#define MAX_DIFF 4.0
		speedFilterWeight[filterI-1]=1.0/(MAX_DIFF+1.0)*diff+MAX_DIFF/(MAX_DIFF+1.0);
	}else {
		speedFilterWeight[filterI-1]=1;	
	}
	
	//3. compute the resulting speed
	gps_data.fix.speed=0.0;
	float weightSum=0.0;
	for(int i=0;i<filterI;i++) {
		gps_data.fix.speed+=speedFilter[i];
		weightSum+=speedFilterWeight[filterI-1];
	}
	gps_data.fix.speed/=weightSum;	
	//Update signal quality
	signalQuality=100;
	
	if(newLocation.horizontalAccuracy>=0) gps_data.fix.mode=2;
	if(newLocation.verticalAccuracy>=0) gps_data.fix.mode=3;
	
	
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
	
	
	gps_data.fix.latitude=newLocation.coordinate.latitude;
	gps_data.fix.longitude=newLocation.coordinate.longitude;
	gps_data.fix.altitude=newLocation.altitude;
	chMsg.state=POS;
	
	[delegate gpsChanged:chMsg];
	chMsg.state=SPEED;
	[delegate gpsChanged:chMsg];
		chMsg.state=SIGNAL_QUALITY;
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
}
@end
