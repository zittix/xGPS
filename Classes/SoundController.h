//
//  SoundController.h
//  xGPS
//
//  Created by Mathieu on 28.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundEvent.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SoundController : NSObject {
	SoundEvent *chain;
	BOOL running;
	NSTimer *tmrSoundCheck;
	int checkSoundCounter;
	BOOL precomputing;
	SystemSoundID beepSound;
	NSDictionary *abrev;
}
-(void)addSound:(SoundEvent*)s;
-(void)treatQueue;
-(void)beepPlayed;
-(void)addSound:(SoundEvent*)s after:(SoundEvent*)ePrev;
@end
