//
//  GPSDetailsViewController.h
//  xGPS
//
//  Created by Mathieu on 27.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GPSDetailsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate > {
	UITableView * _tableView;
}
-(void)updateData;
@property (nonatomic,readonly) UITableView* tableView;
@end
