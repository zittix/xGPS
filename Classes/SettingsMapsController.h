//
//  SettingsGeneralController.h
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapTypeViewController.h";

@interface SettingsMapsController : UITableViewController<UIActionSheetDelegate> {
	MapTypeViewController* maptype;
}

@end
