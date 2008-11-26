//
//  WrongWayView.m
//  xGPS
//
//  Created by Mathieu on 26.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WrongWayView.h"


@implementation WrongWayView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:CGRectMake(frame.origin.x,frame.origin.y,130,82)])) {
		UIImageView* back=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wrongway.png"]];
		[self addSubview:back];
		[back release];
		wrongWaylbl=[[UILabel alloc] initWithFrame:CGRectMake(13,13,104,56)];
		wrongWaylbl.backgroundColor=[UIColor clearColor];
		self.backgroundColor=[UIColor clearColor];
		wrongWaylbl.numberOfLines=0;
		wrongWaylbl.textColor=[UIColor whiteColor];
		wrongWaylbl.font=[UIFont boldSystemFontOfSize:23];
		wrongWaylbl.textAlignment=UITextAlignmentCenter;
		wrongWaylbl.minimumFontSize=12;
		wrongWaylbl.highlighted=YES;
		wrongWaylbl.adjustsFontSizeToFitWidth=YES;
		wrongWaylbl.text=NSLocalizedString(@"Wrong\nWay",@"");
		
		[self addSubview:wrongWaylbl];
    }
    return self;
}
-(void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	if(!run) return;
	[UIView beginAnimations:@"animWrongWay" context:nil];
	[UIView setAnimationDelegate:self];
	
	[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
	if(self.alpha<0.5) {
		[UIView setAnimationDuration:0.3];
		self.alpha=1;
	}else{
		[UIView setAnimationDuration:0.8];
		self.alpha=0.1;
	}
	[UIView commitAnimations];
}
-(void)startAnimate {
	if(run) return;
	run=YES;
	[UIView beginAnimations:@"animWrongWay" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
	if(self.alpha<0.5) {
		[UIView setAnimationDuration:0.3];
		self.alpha=1;
	}else{
		[UIView setAnimationDuration:0.8];
		self.alpha=0.1;
	}
	[UIView commitAnimations];
}
-(void)stopAnimate {
	run=NO;
}

- (void)dealloc {
    [super dealloc];
}


@end
