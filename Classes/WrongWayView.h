//
//  WrongWayView.h
//  xGPS
//
//  Created by Mathieu on 26.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;
@interface WrongWayView : UIView {
	UILabel *wrongWaylbl;
	BOOL run;
	id delegate;
}
- (id)initWithFrame:(CGRect)frame withDelegate:(MainViewController*)_del;
-(void)startAnimate;
-(void)stopAnimate;
@end
