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
	[chMsg release];
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
	chMsg=[[ChangedState objWithState:SPEED andParent:self] retain];
	return self;
}
- (void)gpsUpdate {
	gps_data.fix.speed=6;
	
	gps_data.fix.latitude=pos.x;
	gps_data.fix.longitude=pos.y;
	gps_data.fix.altitude=500;
	chMsg.state=POS;
#ifdef USE_UI
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
	chMsg.state=SPEED;
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
	[delegate gpsChanged:chMsg];
	chMsg.state=SPEED;
	[delegate gpsChanged:chMsg];
#endif
	
	//Update signal quality
	signalQuality=100;
	
	if(signalQuality<0) signalQuality=0;
	
	chMsg.state=SIGNAL_QUALITY;
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
	pos.x+=0.0001;
	pos.y+=0.0001;
}
@end
