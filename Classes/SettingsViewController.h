//
//  SettingsViewController.h
//  xGPS
//
//  Created by Mathieu on 8/31/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingsUIController.h"
#import "SettingsGeneralController.h"
#import "SettingsMapsController.h"
#import "SettingsGPSController.h"
#import "SettingsDrivingDirectionsController.h"
#import "SettingsGPXController.h"
@interface SettingsViewController : UITableViewController {
	SettingsUIController* uisettings;
	SettingsGeneralController* generalsettings;
	SettingsMapsController* mapssettings;
	SettingsGPSController* gpssettings;
	SettingsDrivingDirectionsController* dirsettings;
	SettingsGPXController* gpxsettings;
}
- (id)initWithStyle:(UITableViewStyle)style;
-(void)reload;
@end
