//
//  RoutesManagerViewController.h
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RoutesManagerDelegate
-(void)setEditingKeyBoard;
@end


@interface RoutesManagerViewController : UITableViewController {
	NSArray* bookmarks;
	id delegate;
}
-(id)initWithStyle:(UITableViewStyle)style delegate:(id<RoutesManagerDelegate>)_delegate;
@end
