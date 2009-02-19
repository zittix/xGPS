//
//  RouteCell.h
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteCell : UITableViewCell {
	UILabel *lblFrom;
	UILabel *lblTo;
	UILabel *lblName;
}
@property (nonatomic,readonly) UILabel* lblFrom;
@property (nonatomic,readonly) UILabel* lblTo;
@property (nonatomic,readonly) UILabel* lblName;
@end
