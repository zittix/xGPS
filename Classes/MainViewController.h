//
//  FirstViewController.h
//  xGPS
//
//  Created by Mathieu on 7/30/08.
//  Copyright Xwaves 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TileDB.h"
#import "MapView.h"
#import "GPSController.h"
#import "SettingsViewController.h"
#import "ZoomView.h"
#import "SpeedView.h"
#import "LicenseViewController.h"
#import "SearchPlacesView.h"
#import "GPSSignalView.h"
#import "DrivingDirectionsSearchView.h"
@interface MainViewController : UIViewController<UpdateProtocol,UIActionSheetDelegate> {
	MapView* mapview;
	UIBarButtonItem* btnEnableGPS;
	UIBarButtonItem* btnSettings;
	UIBarButtonItem* btnSearch;
	SettingsViewController* settingsController;
	UIToolbar* toolbar;
	CGRect viewRect;
	UIBarButtonItem* space1;
	UIBarButtonItem* space2;
	TileDB* tiledb;
	UIBarButtonItem* cancelSearch;
	ZoomView* zoomview;
	SpeedView* speedview;
	LicenseViewController* licenseView;
	SearchPlacesView *searchPlacesView;
	DrivingDirectionsSearchView *drivingSearchView;
	GPSSignalView* signalView;
	PositionObj *gpsPos;
	BOOL directionSearch;
}
- (void)gpsChanged:(ChangedState*)msg;
@property (nonatomic,retain,readonly) MapView* mapview;
@property (nonatomic,retain) TileDB* tiledb;

@end
