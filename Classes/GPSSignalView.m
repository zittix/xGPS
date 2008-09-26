//
//  GPSSignalView.m
//  xGPS
//
//  Created by Mathieu on 9/26/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "GPSSignalView.h"


@implementation GPSSignalView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		//47x20
		red=[[UIImage imageNamed:@"red.png"] retain];
		green=[[UIImage imageNamed:@"green.png"] retain];
		orange=[[UIImage imageNamed:@"orange.png"] retain];
		
		[self setBackgroundColor:[UIColor clearColor]];
		gps=[[UILabel alloc] initWithFrame:CGRectMake(0,22,frame.size.width,18)];
		gps.font=[UIFont fontWithName:@"Helvetica" size:14];
		gps.textAlignment=UITextAlignmentCenter;
		gps.text=@"GPS";
		gps.backgroundColor=[UIColor clearColor];
		gps.textColor=[UIColor darkGrayColor];
		[self addSubview:gps];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	//CGContextRef context=UIGraphicsGetCurrentContext();
	//CGContextSetShadow(context, CGSizeMake(2,-2), 2);
	if(quality<33)
	[red drawAtPoint:CGPointMake(0,0)];
	else if(quality >=33 && quality < 66)
	[orange drawAtPoint:CGPointMake(0,0)];
	else
	[green drawAtPoint:CGPointMake(0,0)];
	
	[super drawRect:rect];
}

-(void)setQuality:(int)q {
	quality=q;
	[self setNeedsDisplay];
}
- (void)dealloc {
	[red release];
	[orange release];
	[green release];
	[gps release];
    [super dealloc];
}


@end
