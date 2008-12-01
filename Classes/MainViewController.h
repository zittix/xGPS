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
#import "DirectionsController.h"
#import "NavigationInstructionView.h"
#import "DirectionsBookmarksViewController.h"
#import "WrongWayView.h"
@interface MainViewController : UIViewController<UpdateProtocol,UIActionSheetDelegate,DirectionsControllerDelegate> {
	MapView* mapview;
	UIBarButtonItem* btnEnableGPS;
	UIBarButtonItem* btnSettings;
	UIBarButtonItem* btnSearch;
	SettingsViewController* settingsController;
	UIToolbar* toolbar;
	UIBarButtonItem* space1;
	UIBarButtonItem* space2;
	TileDB* tiledb;
	UIBarButtonItem* cancelSearch;
	UIBarButtonItem* savedDirections;
	ZoomView* zoomview;
	SpeedView* speedview;
	LicenseViewController* licenseView;
	SearchPlacesView *searchPlacesView;
	DrivingDirectionsSearchView *drivingSearchView;
	GPSSignalView* signalView;
	PositionObj *gpsPos;
	BOOL directionSearch;
	NavigationInstructionView *navView;
	DirectionsBookmarksViewController *dirBookmarks;
	int currentSearchType; //1= search, 2=directions
	WrongWayView *wrongWay;
}
- (void)gpsChanged:(ChangedState*)msg;
-(void)cancelDrivingSearch:(id)sender ;
-(void)showWrongWay;
-(void)hideWrongWay;
-(void)clearDirections;
@property (nonatomic,retain,readonly) MapView* mapview;
@property (nonatomic,retain) TileDB* tiledb;
@property (nonatomic) int currentSearchType;
@end
