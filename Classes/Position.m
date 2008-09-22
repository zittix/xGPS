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
+(PositionObj*)positionWithX:(float)x y:(float)y {
	PositionObj *p=[[PositionObj alloc] init];
	p.x=x;
	p.y=y;
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