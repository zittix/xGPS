//
//  MapTile.h
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TILE_SIZE	256.0f
@interface MapTile : UIView {
	CGImageRef image;
	NSData *data;
	CGSize size;
	CGRect rect;
}
- (id)initWithData:(NSData *)d type:(int)type invert:(BOOL)invert;
- (void)drawAtPoint:(CGPoint)p withContext:(CGContextRef) c;
- (void)drawInRect:(CGRect)r withContext:(CGContextRef) c;
@end
