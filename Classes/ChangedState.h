//
//  ChangedState.h
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPSController;
typedef enum {
	VERSION_CHANGE,
	CONNECTION_CHANGE,
	POS,
	SPEED,
	STATE_CHANGE,
	SERIAL,
	SIGNAL_QUALITY
} MSG_TYPE;
@interface ChangedState : NSObject {
	MSG_TYPE state;
	GPSController* parent;
	
}
+(ChangedState*)objWithState:(MSG_TYPE)t andParent:(GPSController*)p;
@property (nonatomic) MSG_TYPE state;
@property (retain,nonatomic) GPSController* parent;
+(NSString*)stringForState:(MSG_TYPE)s;
@end
