//
//  SoundEvent.h
//  xGPS
//
//  Created by Mathieu on 28.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
	Sound_Announce,
	Sound_Radar 
} Sound;
@interface SoundEvent : NSObject {
	Sound snd;
	NSString* text;
	SoundEvent* next;
}
@property (nonatomic,retain) NSString * text;
@property (nonatomic,retain) SoundEvent * next;
@property (nonatomic) Sound snd;
-(id)initWithSound:(Sound)_snd;
-(id)initWithText:(NSString *)_text;
-(SoundEvent*)getLast;
-(id)initWithText:(NSString *)_text andSound:(Sound)s;
@end
