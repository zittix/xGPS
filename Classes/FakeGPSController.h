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
	ChangedState* chMsg;
	int currentIndex;
	NSMutableArray *posArray;
	BOOL gpxLoaded;
	NSString *currentAlt;
	NSString *currentSpeed;
	NSString *currentLat;
	NSString *currentLon;
	NSString* currentFix;
	BOOL parsingTrackPoint;
	BOOL parsingTrackSeg;
	NSMutableString *currentProp;
}
- (id)initWithDelegate:(id)del;
-(void)loadGPX;
@end
