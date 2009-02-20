//
//  SettingsUIController.h
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsUIController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
	UITableView *tableView;
	UIDatePicker *pickerTime;
	UIView *dummyView;
	UIToolbar *toolbarPicker;
	int editingTime;
}
@property (nonatomic,readonly) UITableView *tableView;
@end
