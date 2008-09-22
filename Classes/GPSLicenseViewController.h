//
//  GPSLicenseViewController.h
//  xGPS
//
//  Created by Mathieu on 9/17/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressView.h"

@interface GPSLicenseViewController : UITableViewController<UITextFieldDelegate> {
	UITextField *value;
	ProgressView *progress;
}
-(void)setLicenseValue:(NSString*)val;
@end
