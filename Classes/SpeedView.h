//
//  ZoomView.h
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapTile.h"
@interface SpeedView : UIView {
	float _speed;
	MapTile *speedbgd;
	UILabel *lblspeed;
	UILabel *lblunit;
}
-(id) initWithFrame:(CGRect)f;
-(void)setSpeed:(float)speed;
@end
