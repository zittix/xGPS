//
//  RemainingDistanceTimeView.h
//  xGPS
//
//  Created by Mathieu on 11/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemainingDistanceTimeView : UIView {
	UILabel *lblDist;
	UILabel *lblTotalDist;
	UIView *coutourDist;
	BOOL nightMode;
}
-(void)setDistance:(float)d;
-(void)setTotalDistance:(float)d;
-(void)setTime:(int)sec;
-(void)setNightMode:(BOOL)val;
@end
