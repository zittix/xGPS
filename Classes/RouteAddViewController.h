//
//  RouteAddViewController.h
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchPlacesView.h"
#import "ProgressViewController.h"
#import "DirectionsController.h"
@interface RouteAddViewController : UIViewController<SearchPlacesViewDelegate,DirectionsControllerDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate> {
	NSMutableArray *points;
	int editingRow;
	UISegmentedControl *routeType;
	ProgressViewController *pController;
	UITableView *tableView;
	UITextField *txtName;
}
-(void)clearAll;
@property (nonatomic,readonly) UITableView *tableView;
@end
