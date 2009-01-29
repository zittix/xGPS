//
//  MapTile.m
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "MapTile.h"

@implementation MapTile
- (void)drawRect:(CGRect)r {
	CGContextRef c = UIGraphicsGetCurrentContext();
	[self drawAtPoint:CGPointMake(r.origin.x,r.origin.y) withContext: c];
}
- (id)initWithData:(NSData *)d type:(int)type{
	if((self=[super initWithFrame:CGRectMake(0,0,size.width,size.height)])) {	
		data=d;
		[data retain];
		CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,[data bytes],[data length],NULL);
		if(type==0)
			image = CGImageCreateWithPNGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
		else
			image = CGImageCreateWithJPEGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
		
		size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
		
		CGDataProviderRelease(provider);
	}
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
	CGContextDrawImage(c, CGRectMake(r.origin.x,-r.origin.y,r.size.width,r.size.height), image);
}
@end
