//
//  SpeedView.m
//  xGPS
//
//  Created by Mathieu on 6/24/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "SpeedView.h"

@implementation SpeedView
-(id) initWithFrame:(CGRect)f {
	if((self = [super initWithFrame:f])) {
		NSString* imageFileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"speed.png"];
		NSData *noTileImg = [NSData dataWithContentsOfFile:imageFileName];
		speedbgd=[[MapTile alloc] initWithData: noTileImg];
		[self setBackgroundColor:[UIColor clearColor]];

		lblspeed=[[UILabel alloc] initWithFrame:CGRectMake(13,10,f.size.width-25,f.size.height-40)];
		lblspeed.backgroundColor=[UIColor clearColor];
		lblspeed.textAlignment=UITextAlignmentCenter;
		lblspeed.adjustsFontSizeToFitWidth=YES;
		lblspeed.font=[UIFont fontWithName:@"Helvetica" size:42];
		lblspeed.text=@"0";
		lblunit=[[UILabel alloc] initWithFrame:CGRectMake(13,60,f.size.width-25,20)];
		lblunit.backgroundColor=[UIColor clearColor];
		lblunit.textAlignment=UITextAlignmentCenter;
		lblunit.adjustsFontSizeToFitWidth=YES;
		lblunit.font=[UIFont fontWithName:@"Helvetica" size:12];
		lblunit.text=@"km/h";

		[self addSubview:lblspeed];
		[self addSubview:lblunit];
	}
	return self;
}
-(void)dealloc {
	[speedbgd release];
	[lblspeed release];
	[lblunit release];
	[super dealloc];
}


-(void)setSpeed:(float)speed {
	_speed=speed;
	lblspeed.text=[NSString stringWithFormat:@"%.0f",speed];
}

- (void)drawRect:(CGRect)r {

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context,r);
	

	CGContextScaleCTM(context, 1, -1);
	[speedbgd drawAtPoint:CGPointMake(0,r.size.height) withContext:context];
	CGContextScaleCTM(context, 1, -1);
	[super drawRect:r];
	
}
@end
