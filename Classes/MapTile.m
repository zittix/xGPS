//
//  MapTile.m
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "MapTile.h"

@implementation MapTile
- (id)initWithData:(NSData *)d withRect:(CGRect) r {
	self=[super initWithFrame:r];
	rect=r;
	[self initWithData:d];
	return self;
}
- (void)drawRect:(CGRect)r {
	NSLog(@"Paint");
	CGContextRef c = UIGraphicsGetCurrentContext();
	[self drawAtPoint:CGPointMake(r.origin.x,r.origin.y) withContext: c];
}
- (id)initWithData:(NSData *)d {
	if(self ==nil) {
		self=[super initWithFrame:CGRectMake(0,0,size.width,size.height)];
	}
	data=d;
	[data retain];
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,[data bytes],[data length],NULL);
	image = CGImageCreateWithPNGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
	size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	CGDataProviderRelease(provider);
	return self;
}
- (void)dealloc {
	CGImageRelease(image);
	[data release];
	[super dealloc];
}
- (void)drawAtPoint:(CGPoint)p withContext:(CGContextRef) c {
	CGContextDrawImage(c, CGRectMake(p.x, -p.y, size.width, size.height), image);
}
- (void)drawInRect:(CGRect)r withContext:(CGContextRef) c {
	//NSLog(@"Drawing at pos %f %f with size: %f %f",r.origin.x,r.origin.y,r.size.width,r.size.height);
	CGContextDrawImage(c, CGRectMake(r.origin.x,-r.origin.y,r.size.width,r.size.height), image);
}
@end
