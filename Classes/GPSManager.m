//
//  GPSManager.m
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "GPSManager.h"
#import "xGPSController.h"
#import "iGPSDController.h"
#import "iPhone3GController.h"
#import "xGPSAppDelegate.h"
#import "FakeGPSController.h"
#import "iGPS360Controller.h"
@implementation GPSManager
@synthesize idGPS;
-(id)init {
	
	if((self=[super init])) {
		NSLog(@"Init manager");
		int id_setting=[[NSUserDefaults standardUserDefaults] integerForKey: kSettingsCurrentGPS];
		if(id_setting<=0 || id_setting>NBGPS) {
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kSettingsCurrentGPS];
			idGPS=1;
		} else
			idGPS=id_setting;
		
		delegate=self;
		NSLog(@"End Init manager");
	}
	
	return self;
}
-(void)setDelegate:(id)del {
	delegate=del;
	[self GetGPSWithId:idGPS].delegate=delegate;
}
-(void)dealloc {
	[[self GetCurrentGPS] stop];
	[gpsControllers1 release];
	[gpsControllers2 release];
	[gpsControllers3 release];
	[gpsControllers4 release];
	[gpsControllers5 release];
	[super dealloc];
}
-(void)setCurrentGPS:(int)_id {
	if(_id>0 && _id<NBGPS+1) {

		idGPS=_id;
		[[NSUserDefaults standardUserDefaults] setInteger:idGPS forKey:kSettingsCurrentGPS];
	}	
}
-(GPSController*)GetCurrentGPS {
	return [self GetGPSWithId:idGPS];
}
-(NSString*)GetCurrentGPSName {
	return [self GetGPSName:idGPS];
}
-(NSString*)GetGPSName:(int)id {
	if(id<=NBGPS && id>0) {
		return [self GetGPSWithId:id].name;
	}
	return @"Invalid ID";
}
- (void)gpsChanged:(ChangedState*)msg {
}
-(GPSController*)GetGPSWithId:(int)_id {
	
	if(_id<=0 || _id>NBGPS) return nil;

		id del=(delegate!=nil ? delegate : self);
	GPSController *gps=nil;
		switch(_id) {
			case 1:
				if(gpsControllers1==nil)
				gpsControllers1=[[xGPSController alloc] initWithDelegate:del];
				gps=gpsControllers1;
				break;
			case 2:
				if(gpsControllers2==nil)
				gpsControllers2=[[iPhone3GController alloc] initWithDelegate:del];
				gps=gpsControllers2;
				break;
			case 3:
				if(gpsControllers3==nil)
				gpsControllers3=[[iGPSDController alloc] initWithDelegate:del];
				gps=gpsControllers3;
				break;
			case 4:
				if(gpsControllers4==nil)
					gpsControllers4=[[iGPS360Controller alloc] initWithDelegate:del];
				gps=gpsControllers4;
				break;
			case 5:
				if(gpsControllers5==nil)
					gpsControllers5=[[FakeGPSController alloc] initWithDelegate:del];
				gps=gpsControllers5;
				
				break;
	}
	gps.delegate=delegate;
	return gps;
}
-(NSDictionary*)GetAllGPSNames {
	/* Build the GPS list */
	NSMutableDictionary* dict=[NSMutableDictionary dictionaryWithCapacity:NBGPS];
	for(int i=1;i<=NBGPS;i++) {
		[dict setObject:[self GetGPSName:i] forKey:[NSNumber numberWithInt:i]];
	}
	return dict;
}
@end
