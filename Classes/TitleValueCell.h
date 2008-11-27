//
//  TitleValueCell.h
//  xGPS
//
//  Created by Mathieu on 27.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TitleValueCell : UITableViewCell {
	UILabel *titlelbl;
	UILabel *valuelbl;
}
@property(nonatomic,assign) NSString * title;
@property(nonatomic,assign) NSString * value;
@end
