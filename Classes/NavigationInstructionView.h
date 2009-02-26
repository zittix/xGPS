//
//  NavigationInstructionView.h
//  xGPS
//
//  Created by Mathieu on 11/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrivingInstructionMovingProtocol
-(void)previousDrivingInstructions;
-(void)nextDrivingInstructions;
@end

@interface NavigationInstructionView : UIView {
	UILabel *lbl;
	CGPoint startTouchPosition;
	id delegate;
	int swipeDir;
	BOOL nightMode;
}
@property(nonatomic,assign) id delegate;
-(void)setText:(NSString*)txt;
-(void)setTextSize:(float)size;
-(void)setNightMode:(BOOL)val;
-(void)fontChanged;
@end
