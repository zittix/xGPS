//
//  xGPSAppDelegate.h
//  xGPS
//
//  Created by Mathieu on 7/30/08.
//  Copyright Xwaves 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TileDB.h"
#import "DirectionsController.h"
#import "GPSManager.h"
#import "DirectionsBookmarks.h"
#define kSettingsCurrentGPS @"gpsinuse"
#define kSettingsLicense @"gpslicense_%@"
#define kSettingsLicenseOK @"gpslicense_%@_status"
#define kSettingsConditionsUse @"conditionofuse"
#define kSettingsLastPosX @"gpslastposx"
#define kSettingsLastPosY @"gpslastposy"
#define vSettingsConditionsUse @"1.0"
#define kSettingsMapsOffline @"mapsofflinemode"
#define kSettingsMapsLanguage @"mapslanguage"
#define kSettingsSleepMode @"preventsleepmode"
#define kSettingsDBVersion @"dbversion"
#define kSettingsVersion @"settingsversion"
#define kSettingsMapRotation @"maprotation"
#define kSettingsGPSLog @"gpslog"
#define kSettingsSpeedUnit @"speedunit"
#define kSettingsDirBookmarksDBVersion @"dirbookmarkversion"
#define kSettingsUseGPSBall @"usegpsball"
#define kSettingsShowSpeed @"showspeed"
#define APPDELEGATE ((xGPSAppDelegate*)[UIApplication sharedApplication])
#define VERSION "1.1.0 Test"
@interface xGPSAppDelegate : UIApplication <UIApplicationDelegate> {
	UIWindow *window;
	UINavigationController *navController;
}

+(TileDB*)tiledb;
+(GPSManager*)gpsmanager;
+(xGPSAppDelegate*)appdelegate;
+(xGPSAppDelegate*)appdelegate;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, readonly,getter=tiledb) TileDB* tiledb;
@property (nonatomic, readonly,getter=gpsmanager) GPSManager* gpsmanager;
@property (nonatomic, readonly,getter=directions) DirectionsController* directions;
@property (nonatomic, readonly,getter=dirbookmarks) DirectionsBookmarks* dirbookmarks;
@end
