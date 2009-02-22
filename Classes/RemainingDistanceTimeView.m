//
//  RemainingDistanceTimeView.m
//  xGPS
//
//  Created by Mathieu on 11/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "RemainingDistanceTimeView.h"
#import "xGPSAppDelegate.h"

@implementation RemainingDistanceTimeView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		//132 152 179
		//[UIColor colorWithRed:0.51764705f green:0.5960784314f blue:0.7019607843 alpha:1]
		self.backgroundColor=[UIColor clearColor];
		lblDist=[[UILabel alloc] initWithFrame:CGRectMake(10,0,frame.size.width-20,frame.size.height)];
		
		coutourDist=[[UIView alloc] initWithFrame:CGRectMake(0,0,50,30)];
		coutourDist.backgroundColor=[UIColor colorWithRed:0.51764705f green:0.5960784314f blue:0.7019607843 alpha:0.6];
		[self addSubview:coutourDist];
		lblDist.textAlignment=UITextAlignmentCenter;
		lblDist.backgroundColor=[UIColor clearColor];
		lblDist.textColor=[UIColor whiteColor];
		lblDist.font=[UIFont boldSystemFontOfSize:16];
		lblDist.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		[coutourDist addSubview:lblDist];
		lblDist.text=@"256 m";
    }
    return self;
}

-(void)setNightMode:(BOOL)val {
	[UIView beginAnimations:nil context:nil];
	if(val)
	self.backgroundColor=[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1];
	else
		self.backgroundColor=[UIColor colorWithRed:0.51764705f green:0.5960784314f blue:0.7019607843 alpha:1];
	[UIView commitAnimations];
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.width-=20;
	CGSize lblSize=[lblDist sizeThatFits:size];
	lblSize.width=self.frame.size.width;
	lblSize.height=MAX(lblSize.height,30);
	return lblSize;
}
-(void)setDistance:(float)d {
	
}
-(void)setTime:(int)sec {
	
}
-(void)setTotalDistance:(float)d {
	
}
- (void)dealloc {
	[lblDist release];
    [super dealloc];
}


@end
