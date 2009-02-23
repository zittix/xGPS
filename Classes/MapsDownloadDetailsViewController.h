//
//  MapsDownloadDetailsViewController.h
//  xGPS
//
//  Created by Mathieu on 23.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MapsDownloadDetailsDelegate

-(void)gotName:(NSString*)name andZoomLevel:(int)zoom;

@end


@interface MapsDownloadDetailsViewController : UITableViewController<UITextFieldDelegate> {
	id delegate;
	UITextField *txtName;
	UISlider *slideZoom;
}
- (id)initWithStyle:(UITableViewStyle)style delegate:(id<MapsDownloadDetailsDelegate>)_delegate;
@end
