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
@interface SettingsViewController : UITableViewController<UIActionSheetDelegate> {
	UIButton *btnMaps;
	MapsManagerView* mapsmanager;
	MapView *_mapview;
	GPSSelectorViewController *gpsselector;
	TileDB *db;
}
- (id)initWithStyle:(UITableViewStyle)style withMap:(MapView*)mapview withDB:(TileDB*)_db;

@end
