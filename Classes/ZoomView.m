//
//  ZoomView.m
//  xGPS
//
//  Created by Mathieu on 6/24/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "ZoomView.h"

@implementation ZoomView
-(id) initWithFrame:(CGRect)f withDelegate:(id)_delegate {
	if((self = [super initWithFrame:f])) {
		delegate=_delegate;
		UIImage* btnImage = [UIImage imageNamed:@"zoomin.png"];
		UIImage* btnImageOut = [UIImage imageNamed:@"zoomout.png"];
		zoomout = [UIButton buttonWithType:UIButtonTypeCustom];
		zoomin = [UIButton buttonWithType:UIButtonTypeCustom];
		zoomin.frame=CGRectMake(0.0, 54.0f, 35, 32);
		zoomout.frame=CGRectMake(0.0, 0.0f, 55, 51);
		zoomin.showsTouchWhenHighlighted=YES;
		zoomout.showsTouchWhenHighlighted=YES;
		zoomout.adjustsImageWhenHighlighted=YES;
		[zoomout setImage:btnImage forState:UIControlStateNormal];


		[zoomin setAlpha:0.7];
		[zoomout setAlpha:0.2];
		[zoomin setImage:btnImageOut forState:UIControlStateNormal];

		[self addSubview:zoomin];
		[self addSubview:zoomout];
		[zoomin addTarget:self action:@selector(zoomoutPressed) forControlEvents:UIControlEventTouchUpInside];
		[zoomout addTarget:self action:@selector(zoominPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}
-(void)zoominPressed {
	[delegate zoomin:self];
}
-(void)zoomoutPressed {
	[delegate zoomout:self];
}
-(void)setZoomoutState:(BOOL)s  {
	[zoomin setAlpha:s ? 0.7 : 0.2];
}
-(void)setZoominState:(BOOL)s {
	[zoomout setAlpha:s ? 0.7 : 0.2];
}
@end
