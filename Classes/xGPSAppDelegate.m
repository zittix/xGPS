//
//  xGPSAppDelegate.m
//  xGPS
//
//  Created by Mathieu on 7/30/08.
//  Copyright Xwaves 2008. All rights reserved.
//

#import "xGPSAppDelegate.h"

#import "GPXLogger.h"
static xGPSAppDelegate* staticObj=nil;
@implementation xGPSAppDelegate
static TileDB* tiledb;
static GPSManager* gpsmanager;
static DirectionsController* directions;
static DirectionsBookmarks* dirbookmarks;
static TransferController* txcontroller;
static GPXLogger* gpxlogger;
static SoundController * soundcontroller;
@synthesize window;
@synthesize navController;
@synthesize navControllerMain;
+(xGPSAppDelegate*)appdelegate {
	return staticObj;
}
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	gpxlogger=[[GPXLogger alloc] init];
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsGPSLog])
		[gpxlogger startLogging];
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsVersion]<2) {
		[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:kSettingsVersion];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingsShowSpeed];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingsSaveDirSearch];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingsRecomputeDriving];
	}
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsVersion]<3) {
		[[NSUserDefaults standardUserDefaults] setInteger:3 forKey:kSettingsVersion];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingsRecomputeDriving];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingsWrongWayHidden];
	}
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsVersion]<4) {
		[[NSUserDefaults standardUserDefaults] setInteger:4 forKey:kSettingsVersion];
		[[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:kSettingsLastUsedBookmark];
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kSettingsMapType];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingsEnableVoiceInstr];
	}
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsVersion]<5) {
		[[NSUserDefaults standardUserDefaults] setInteger:5 forKey:kSettingsVersion];
		[[NSUserDefaults standardUserDefaults] setObject:@"20:00" forKey:kSettingsTimerNightStart];
		[[NSUserDefaults standardUserDefaults] setObject:@"7:00" forKey:kSettingsTimerNightStop];
	}
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsVersion]<6) {
		[[NSUserDefaults standardUserDefaults] setInteger:6 forKey:kSettingsVersion];
		[[NSUserDefaults standardUserDefaults] setInteger:-1 forKey:kSettingsLastUsedBookmark];
	}
	
	staticObj=self;
	txcontroller=[[TransferController alloc] init];
	soundcontroller=[[SoundController alloc] init];
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	dirbookmarks=[[DirectionsBookmarks alloc] init];
	tiledb=[[TileDB alloc] init];
	gpsmanager=[[[GPSManager alloc] init] retain];
	[[gpsmanager GetCurrentGPS] start];
	navControllerMain = [[MainViewController alloc] init];
	
	// create a navigation controller using the new controller
	navController = [[UINavigationController alloc] initWithRootViewController:navControllerMain];
	
	directions=[[DirectionsController alloc] init];
	directions.delegate=navControllerMain;
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:navController.view];

	[window makeKeyAndVisible];
	
	self.idleTimerDisabled=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSleepMode];
		
}
- (void)applicationWillTerminate:(UIApplication *)application {
	[[gpsmanager GetCurrentGPS] stop];
	//Save current itinaeray
	[[NSUserDefaults standardUserDefaults] setInteger:directions.currentBookId forKey:kSettingsLastUsedBookmark];	
	[gpxlogger stopLogging];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
-(TileDB*)tiledb {
	return tiledb;
}
-(DirectionsBookmarks*)dirbookmarks {
	return dirbookmarks;
}
-(DirectionsController*)directions {
	return directions;
}
-(TransferController*)txcontroller {
	return txcontroller;
}
-(SoundController*)soundcontroller {
	return soundcontroller;
}

+(TileDB*)tiledb {
	return tiledb;
}
+(GPSManager*)gpsmanager {
	return gpsmanager;
}
-(GPSManager*)gpsmanager {
	return gpsmanager;
}
-(GPXLogger*)gpxlogger {
	return gpxlogger;
}
- (void)dealloc {
	[navController release];
	[window release];
	[tiledb release];
	[dirbookmarks release];
	[gpsmanager release];
	[txcontroller release];
	[navControllerMain release];
	[super dealloc];
}

@end

