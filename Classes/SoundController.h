//
//  SoundController.h
//  xGPS
//
//  Created by Mathieu on 28.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundEvent.h"

@interface SoundController : NSObject {
	SoundEvent *chain;
	BOOL running;
	NSTimer *tmrSoundCheck;
	int checkSoundCounter;
}
-(void)addSound:(SoundEvent*)s;
-(void)treatQueue;
-(void)addSound:(SoundEvent*)s after:(SoundEvent*)ePrev;
@end
