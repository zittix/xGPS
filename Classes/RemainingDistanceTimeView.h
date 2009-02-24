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
	BOOL miles;
	double totalDist;
	double dist;
}
-(void)setDistance:(double)d;
-(void)setTotalDistance:(double)d;
-(void)setTime:(int)sec;
-(void)setNightMode:(BOOL)val;
@end
