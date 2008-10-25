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
+(NSString*)stringForState:(MSG_TYPE)s {
	switch(s) {
		case POS: return @"POS";
			case VERSION_CHANGE: return @"VERSION_CHANGE";
			case CONNECTION_CHANGE: return @"CONNECTION_CHANGE";
			case SPEED: return @"SPEED";
			case STATE_CHANGE: return @"STATE_CHANGE";
			case SERIAL: return @"SERIAL";
			case SIGNAL_QUALITY: return @"SIGNAL_QUALITY";
			
	}
	return @"";
}
@end
