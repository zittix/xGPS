//
//  DirectionsLanguageViewController.h
//  xGPS
//
//  Created by Mathieu on 9/23/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DirectionsLanguageViewController : UIView<UIPickerViewDelegate,UIPickerViewDataSource> {
	UIPickerView *picker;
	UIToolbar* toolbar;
	UITableViewController* _cnt;

}
-(id)initWithFrame:(CGRect)f andController:(UITableViewController*)cnt;
@end
