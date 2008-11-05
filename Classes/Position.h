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
	int tileX;
	int tileY;
	int xoff;
	int yoff;
}
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) int yoff;
@property (nonatomic) int xoff;
@property (nonatomic) int tileX;
@property (nonatomic) int tileY;
+(PositionObj*)positionWithX:(float)x y:(float)y;
@end

@interface TileCoord : NSObject
{
	int x;
	int y;
	unsigned char zoom;
	id delegate;
}
@property (nonatomic) int x;
@property (nonatomic) int y;
@property (nonatomic,retain) id delegate;
@property (nonatomic) unsigned char zoom;
+(TileCoord*)tileCoordWithX:(int)x y:(int)y zoom:(int)zoom delegate:(id)delegate;
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