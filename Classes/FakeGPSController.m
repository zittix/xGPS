//
//  FakeGPSController.m
//  xGPS
//
//  Created by Mathieu on 9/26/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "FakeGPSController.h"


@implementation FakeGPSController

- (BOOL)EnableGPS {
	if(tmrGPS==nil)
	tmrGPS=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(gpsUpdate) userInfo:nil repeats:YES];
	
	isEnabled=YES;
	
	return YES;
}
- (BOOL)DisableGPS {
	if(tmrGPS!=nil) {
		[tmrGPS invalidate];
		tmrGPS=nil;
	}
	isEnabled=NO;
		return YES;
}
-(NSString*)name {
	return @"Fake GPS";
}
-(void) dealloc {
	[pos release];
	[super dealloc];
}
- (id)initWithDelegate:(id)del {
	self=[super initWithDelegate:del];
	pos=[[PositionObj alloc] init];
	pos.x=48.847639;
	pos.y=2.367715;
	version_minor=0;
	version_major=1;
	validLicense=YES;
	isConnected=YES;
	return self;
}
- (void)gpsUpdate {
	gps_data.fix.speed=6;
	
	gps_data.fix.latitude=pos.x;
	gps_data.fix.longitude=pos.y;
	gps_data.fix.altitude=500;
#ifdef USE_UI
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:POS andParent:self] waitUntilDone:YES];
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:SPEED andParent:self] waitUntilDone:YES];
#else
	[delegate gpsChanged:[ChangedState objWithState:POS andParent:self]];
	[delegate gpsChanged:[ChangedState objWithState:SPEED andParent:self]];
#endif
	
	//Update signal quality
	signalQuality=100;
	
	if(signalQuality<0) signalQuality=0;
	
	
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:SIGNAL_QUALITY andParent:self] waitUntilDone:YES];
	pos.x+=0.0001;
	pos.y+=0.0001;
}
@end
