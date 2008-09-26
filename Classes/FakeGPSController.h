//
//  FakeGPSController.h
//  xGPS
//
//  Created by Mathieu on 9/26/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChangedState.h"
#import "GPSController.h"
#import "Position.h"
@interface FakeGPSController : GPSController {
	NSTimer *tmrGPS;
	PositionObj *pos;
}
- (id)initWithDelegate:(id)del;
@end
