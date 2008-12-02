//
//  SpeedView.m
//  xGPS
//
//  Created by Mathieu on 6/24/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "SpeedView.h"
#import "xGPSAppDelegate.h"
@implementation SpeedView
-(id) initWithFrame:(CGRect)f {
	if((self = [super initWithFrame:f])) {
		miles=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit];
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
		if(miles)
		lblunit.text=@"mph";
			else
		lblunit.text=@"km/h";

		[self addSubview:lblspeed];
		[self addSubview:lblunit];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
	}
	return self;
}
-(void)unitChanged:(NSNotification *)notif {
	miles=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit];
	lblspeed.text=@"0";
	_speed=0;
	if(miles)
		lblunit.text=@"mph";
	else
		lblunit.text=@"km/h";
}
-(void)dealloc {
	[speedbgd release];
	[lblspeed release];
	[lblunit release];
	[super dealloc];
}


-(void)setSpeed:(double)speed {
	//1 mph = 1.609 km/h
	if(miles)
		speed*=0.62150404f;
	_speed=speed;
	lblspeed.text=[NSString stringWithFormat:@"%.0f",speed];
	[lblspeed setNeedsDisplay];
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
