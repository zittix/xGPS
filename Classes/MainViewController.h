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
#import "WrongWayView.h"
#import "GPSDetailsViewController.h"
#import "ViewSearch.h"
#import "RemainingDistanceTimeView.h"
@interface MainViewController : UIViewController<UpdateProtocol,UIActionSheetDelegate,DirectionsControllerDelegate,ShowGPSDetailProtocol,SearchPlacesViewDelegate,ViewSearchProtocol> {
	MapView* mapview;
	UIButton* btnSettings;
	UIButton* btnSearch;
	SettingsViewController* settingsController;
	TileDB* tiledb;
	UIBarButtonItem* cancelSearch;
	UIBarButtonItem* routesManager;
	ZoomView* zoomview;
	SpeedView* speedview;
	LicenseViewController* licenseView;
	SearchPlacesView *searchPlacesView;
	DrivingDirectionsSearchView *drivingSearchView;
	GPSSignalView* signalView;
	PositionObj *gpsPos;
	BOOL directionSearch;
	NavigationInstructionView *navView;
	int currentSearchType; //1= search, 2=directions
	WrongWayView *wrongWay;
	NSTimer * tmrNightMode;
	GPSDetailsViewController *gpsdetails;
	RemainingDistanceTimeView *remainingView;
	ViewSearch *viewSearch;
	BOOL hidden;

}
-(void)setGPSMode:(int)mode;
- (void)gpsChanged:(ChangedState*)msg;
-(void)cancelDrivingSearch:(id)sender ;
-(void)showWrongWay;
-(void)hideWrongWay;
-(void)clearDirections;
- (void)setStatusIconVisible:(BOOL)visible state:(int)state;
-(void)speedChanged:(NSNotification *)notif;
@property (nonatomic,retain,readonly) MapView* mapview;
@property (nonatomic,retain) TileDB* tiledb;
@property (nonatomic) int currentSearchType;
@end
