//
//  ZoomView.h
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapTile.h"
@protocol ShowGPSDetailProtocol

-(void)showGPSDetails;

@end
@interface SpeedView : UIView {
	float _speed;
	MapTile *speedbgd;
	UILabel *lblspeed;
	UILabel *lblunit;
	id delegate;
	BOOL miles;
}
-(id) initWithFrame:(CGRect)f delegate:(id<ShowGPSDetailProtocol>)_delegate;
-(void)setSpeed:(double)speed;
@end
