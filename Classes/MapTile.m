//
//  MapTile.m
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "MapTile.h"


CGContextRef MyCreateBitmapContext (int pixelsWide,
									
									int pixelsHigh)

{
	
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
   // void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
	
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);

    colorSpace = CGColorSpaceCreateDeviceRGB();
	
   /* bitmapData = malloc( bitmapByteCount );// 3
	
    if (bitmapData == NULL)
		
    {
		
        fprintf (stderr, "Memory not allocated!");
		
        return NULL;
		
    }*/
	
    context = CGBitmapContextCreate (NULL,// 4
									 
									 pixelsWide,
									 
									 pixelsHigh,
									 
									 8,      // bits per component
									 
									 bitmapBytesPerRow,
									 
									 colorSpace,
									 
									 kCGImageAlphaNoneSkipLast);
	
    if (context== NULL)
		
    {
		
       // free (bitmapData);// 5
		
        fprintf (stderr, "Context not created!");
		
        return NULL;
		
    }
	
    CGColorSpaceRelease( colorSpace );// 6
	
	
	
    return context;// 7
	
}


@implementation MapTile
- (void)drawRect:(CGRect)r {
	CGContextRef c = UIGraphicsGetCurrentContext();
	[self drawAtPoint:CGPointMake(r.origin.x,r.origin.y) withContext: c];
}
- (id)initWithData:(NSData *)d type:(int)type invert:(BOOL)invert{
	if((self=[super initWithFrame:CGRectMake(0,0,size.width,size.height)])) {	
		data=d;
		[data retain];
		CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,[data bytes],[data length],NULL);
		if(type==0)
			image = CGImageCreateWithPNGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
		else
			image = CGImageCreateWithJPEGDataProvider(provider, NULL, true, kCGRenderingIntentDefault);
		size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
		if(invert) {
			CGContextRef context=MyCreateBitmapContext(size.width, size.height);
			CGContextSetRGBFillColor(context, 1, 1, 1, 1);
			CGContextFillRect(context,CGRectMake(0,0,size.width,size.height));
			CGContextSetBlendMode(context,kCGBlendModeExclusion);
			CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image);
			CGImageRelease(image);
			[data release];
			data=nil;
			image=CGBitmapContextCreateImage(context);
			CGContextRelease(context);
			
		}
		
		
		
		
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
