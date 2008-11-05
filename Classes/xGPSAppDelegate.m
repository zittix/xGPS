//
//  xGPSAppDelegate.m
//  xGPS
//
//  Created by Mathieu on 7/30/08.
//  Copyright Xwaves 2008. All rights reserved.
//

#import "xGPSAppDelegate.h"
#import "MainViewController.h"
#import "GPXLogger.h"
static xGPSAppDelegate* staticObj=nil;
@implementation xGPSAppDelegate
static TileDB* tiledb;
static GPSManager* gpsmanager;
static DirectionsController* directions;
@synthesize window;
@synthesize navController;
+(xGPSAppDelegate*)appdelegate {
	return staticObj;
}
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsGPSLog])
	startGPXLogEngine();
	
	staticObj=self;
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

	tiledb=[[TileDB alloc] init];
	gpsmanager=[[[GPSManager alloc] init] retain];
	[[gpsmanager GetCurrentGPS] start];
	MainViewController *navControllerMain = [[MainViewController alloc] init];
	
	// create a navigation controller using the new controller
	navController = [[UINavigationController alloc] initWithRootViewController:navControllerMain];
	[navControllerMain release];
	directions=[[DirectionsController alloc] init];
	directions.delegate=navControllerMain;
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:navController.view];

	[window makeKeyAndVisible];
	
	self.idleTimerDisabled=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSleepMode];
}
- (void)applicationWillTerminate:(UIApplication *)application {
	[[gpsmanager GetCurrentGPS] stop];
	[[NSUserDefaults standardUserDefaults] synchronize];
	stopGPXLogEngine();
}
-(TileDB*)tiledb {
	return tiledb;
}
-(DirectionsController*)directions {
	return directions;
}
+(TileDB*)tiledb {
	return tiledb;
}
+(GPSManager*)gpsmanager {
	return gpsmanager;
}

- (void)dealloc {
	[navController release];
	[window release];
	[tiledb release];
	[gpsmanager release];
	[super dealloc];
}

@end

