//
//  ChangedState.m
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "ChangedState.h"


@implementation ChangedState
@synthesize state;
@synthesize parent;
+(ChangedState*)objWithState:(MSG_TYPE)t andParent:(GPSController*)p {
	ChangedState* c=[[ChangedState alloc] init];
	c.state=t;
	c.parent=p;
	return [c autorelease];
}
@end
