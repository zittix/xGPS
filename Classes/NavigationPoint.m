//
//  NavigationPoint.m
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NavigationPoint.h"


@implementation NavigationPoint
@synthesize name;
-(id) init {
	if((self=[super init])) {
		pos=[[PositionObj alloc] init];
	}
	return self;
}
-(void)dealloc {
	[pos release];
	[name release];
	[super dealloc];
}
-(void)setPos:(PositionObj*)p {
	pos.x=p.x;
	pos.y=p.y;
}
-(PositionObj*)pos {
	return pos;
}
-(NSString*)description {
	return [NSString stringWithFormat:@"%@ @ %f,%f",name,pos.x,pos.y];
}
@end
