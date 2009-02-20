//
//  Position.m
//  xGPS
//
//  Created by Mathieu on 6/16/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "Position.h"

@implementation PositionObj
@synthesize x;
@synthesize y;
@synthesize yoff;
@synthesize xoff;
@synthesize tileX;
@synthesize tileY;
+(PositionObj*)positionWithX:(double)x y:(double)y {
	PositionObj *p=[[PositionObj alloc] init];
	p.x=x;
	p.y=y;
	return [p autorelease];
}
-(NSString*)description {
	return [NSString stringWithFormat:@"%f,%f",x,y];
}
@end
@implementation TileCoord
@synthesize x;
@synthesize y;
@synthesize zoom;
@synthesize delegate;
+(TileCoord*)tileCoordWithX:(int)x y:(int)y zoom:(int)zoom  delegate:(id)delegate{
	TileCoord *p=[[TileCoord alloc] init];
	p.x=x;
	p.y=y;
	p.delegate=delegate;
	p.zoom=zoom	;
	return [p autorelease];
}
@end


@implementation LineObj
- (PositionObj *)start {
	return start;
}
- (PositionObj *)end {
	return end;
}
- (void)setStart:(PositionObj *)val {
	start=[val retain];
}
- (void)setEnd:(PositionObj *)val {
	end=[val retain];
}
-(void)dealloc {
	if(start!=nil)
	[start release];
	if(end!=nil)
	[end release];
	[super dealloc];
}
@end