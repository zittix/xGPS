//
//  SettingsViewController.h
//  xGPS
//
//  Created by Mathieu on 8/31/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "MapsManagerView.h"
#import "MapView.h"
#import "GPSSelectorViewController.h"
#import "TileDB.h"
#import "NetworkReceiverViewController.h"
#import "SettingsUIController.h"
#import "SettingsGeneralController.h"
#import "SettingsMapsController.h"
@interface SettingsViewController : UITableViewController {
	GPSSelectorViewController *gpsselector;
	NetworkReceiverViewController *receiverView;
	SettingsUIController* uisettings;
	SettingsGeneralController* generalsettings;
	SettingsMapsController* mapssettings;
}
- (id)initWithStyle:(UITableViewStyle)style;
@end
