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
		float trans[4]= {0, 0, 0, 0};
		[self setBackgroundColor:[UIColor colorWithCGColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), trans)]];
		_speed=_lastDrawSpeed=0;
		cachedFontSize.width=-1;
		cachedUnitFontSize.width=-1;
		rect=f;
		visible=NO;
	}
	return self;
}
-(void)dealloc {
	[speedbgd release];
	[super dealloc];
}

-(void)setSpeedVisible:(BOOL)state {
	visible=state;
}
-(void)setSpeed:(float)speed {
	_speed=speed;
	[self setNeedsDisplay];
}
- (void)drawRect:(CGRect)r {

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context,r);
	if(!visible)
	return;

	CGContextScaleCTM(context, 1, -1);
	[speedbgd drawAtPoint:CGPointMake(0,rect.size.height) withContext:context];
	CGContextSetAllowsAntialiasing(context,YES);
	CGContextSetShouldAntialias(context,YES);
	NSString* txt=[NSString stringWithFormat:@"%.0f",round(_speed)];
	CGContextSelectFont(context, "Helvetica", 42, kCGEncodingMacRoman);
	BOOL redraw=_lastDrawSpeed!=_speed ? YES  : NO;
	if(cachedFontSize.width>0) {
		CGContextSetTextPosition(
				context, (rect.size.width-cachedFontSize.width)/2.0-2,-(rect.size.height)/2.0-4);
	} else {
		CGContextSetTextPosition(
				context, -555,555);
		redraw=YES;
	}
	CGPoint before=CGContextGetTextPosition(context);

	CGContextShowText(context,[txt UTF8String],[txt length]);
	CGPoint after=CGContextGetTextPosition(context);
	cachedFontSize.width=fabs(after.x-before.x);
	cachedFontSize.height=fabs(after.y-before.y);
	if(cachedUnitFontSize.width>0 ) {
		CGContextSetTextPosition(
				context, (rect.size.width-cachedUnitFontSize.width)/2.0,-rect.size.height+25);
	} else {
		CGContextSetTextPosition(
				context, -444,444);
		redraw=YES;
	}
	before=CGContextGetTextPosition(context);
	CGContextSetFontSize(context,14);

	CGContextShowText(context,"km/h",4);
	after=CGContextGetTextPosition(context);
	cachedUnitFontSize.width=fabs(after.x-before.x);
	cachedUnitFontSize.height=fabs(after.y-before.y);
	CGContextScaleCTM(context, 1, -1);
	_lastDrawSpeed=_speed;
	//NSLog(@"Cached: %f %f",cachedFontSize.width,cachedFontSize.height);
	if(redraw) {
		//NSLog(@"Redrawing...");
		[self drawRect:rect];
	}
}
@end
