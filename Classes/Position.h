//
//  Position.h
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PositionObj : NSObject
{
	float x;
	float y;
}
@property (nonatomic) float x;
@property (nonatomic) float y;
+(PositionObj*)positionWithX:(float)x y:(float)y;
@end
@interface LineObj : NSObject
{
	PositionObj *start;
	PositionObj *end;
}
- (PositionObj *)start;
- (PositionObj *)end;
- (void)setStart:(PositionObj *)val;
- (void)setEnd:(PositionObj *)val;
@end