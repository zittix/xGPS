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
#import "DirectionsLanguageViewController.h"
#import "AboutViewController.h"
#import "NetworkReceiverViewController.h"
@interface SettingsViewController : UITableViewController<UIActionSheetDelegate> {
	MapsManagerView* mapsmanager;
	MapView *_mapview;
	GPSSelectorViewController *gpsselector;
	TileDB *db;
	DirectionsLanguageViewController *dirLangView;
	AboutViewController* aboutView;
	BOOL enabled;
	NetworkReceiverViewController *receiverView;
}
- (id)initWithStyle:(UITableViewStyle)style withMap:(MapView*)mapview withDB:(TileDB*)_db;
-(void) setEnabled:(BOOL)v;
@end
