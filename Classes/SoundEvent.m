//
//  SoundEvent.m
//  xGPS
//
//  Created by Mathieu on 28.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SoundEvent.h"


@implementation SoundEvent
@synthesize snd;
@synthesize text;
@synthesize next;
@synthesize w;
-(id)initWithSound:(Sound)_snd{
	if((self=[super init])) {
		snd=_snd;
	}
	return self;
}
-(SoundEvent*)getLast {
	SoundEvent *last=self;
	while(last.next!=nil) {
		last=last.next;
	}
	return last;
}
-(id)initWithText:(NSString *)_text {
	if((self=[super init])) {
		text=[_text retain];
		snd=-1;
	}
	return self;
}
-(id)initWithText:(NSString *)_text andSound:(Sound)s {
	if((self=[super init])) {
		next=[[SoundEvent alloc] initWithText:_text];
		snd=s;
	}
	return self;
}
-(void)dealloc {
	[next release];
	[text release];
	[super dealloc];
}
@end
