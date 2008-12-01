//
//  SettingsGeneralController.h
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapsManagerView.h"
#import "NetworkReceiverViewController.h"
@interface SettingsMapsController : UITableViewController<UIActionSheetDelegate> {
	MapsManagerView* mapsmanager;
	NetworkReceiverViewController *receiverView;
}

@end
