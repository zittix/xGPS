//
//  xGPSAppDelegate.h
//  xGPS
//
//  Created by Mathieu on 7/30/08.
//  Copyright Xwaves 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TileDB.h"
#import "GPSManager.h"

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
#define APPDELEGATE ((xGPSAppDelegate*)[UIApplication sharedApplication])
@interface xGPSAppDelegate : UIApplication <UIApplicationDelegate> {
	UIWindow *window;
	UINavigationController *navController;
}

+(TileDB*)tiledb;
+(GPSManager*)gpsmanager;
+(xGPSAppDelegate*)appdelegate;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain,readonly,getter=tiledb) TileDB* tiledb;
@end
