//
//  DirectionsBookmarksViewController.h
//  xGPS
//
//  Created by Mathieu on 25.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DirectionsBookmarksDelegate
-(void)bookmarkSelected:(NSString*)from to:(NSString*)to instr:(NSArray*)instr roadPoints:(NSArray*)roadPoints;
-(void)setEditingKeyBoard;
@end

@interface DirectionsBookmarksViewController : UITableViewController {
	id delegate;
	NSArray* bookmarks;
}
-(id)initWithStyle:(UITableViewStyle)style delegate:(id)_delegate;
@end
