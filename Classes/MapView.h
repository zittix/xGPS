//
//  MapView.h
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MapTile.h"
#import "TileDB.h"
#import "LocationWrapper.h"
#import "ZoomView.h"

@interface MapView : UIView<LocationWrapperProtocol,ZoomingProtocol,TileDownloadProtocol> {
	//MapTile
	TileDB *db;
	PositionObj* pos;
	PositionObj* posGPS;
	PositionObj *nextDirection;

	NSMutableDictionary* tilescache;
	BOOL hasGPSfix;
	BOOL dragging;
	CGPoint lastDragPoint;
	int zoom;
	float prevDist;
	float dynTileSize;
	MapTile* imgPinRef;
	MapTile* imgPinSearch;
	MapTile* imgGoogleLogo;

	CGPoint drawOrigin;
	MapTile* tileNoMap;
	BOOL passDoubleFingersEvent;
	NSMutableArray *lines;
	int direction;
	PositionObj *posSearch;
	//UITouch *lastTouch;
	
	
	float mapRotation;
	BOOL gpsTracking;

}
@property(retain,nonatomic) PositionObj *pos;
-(void)refreshMap;
-(id)initWithFrame:(CGRect)f withDB:(TileDB*)_db;
-(void)tileDownloaded;
-(void)setGPSTracking:(BOOL)val;
-(void)setNextDirection:(PositionObj*)p;
-(void)setZoom:(int)z;
-(void)zoomin:(id)sender;
-(void)setDir:(id)d;
-(void)zoomout:(id)sender;
-(void)clearPoints;
-(void)setPosSearch:(PositionObj*)p;
+(float)getMetersPerPixel:(float)latitude zoom:(int)zoom;
-(float)getMetersPerPixel:(float)latitude;
-(void)addDrawPoint:(PositionObj*)p;
-(PositionObj*)getCurrentPos;
- (void)setHasGPSPos:(BOOL)val;
-(void)setPassDoubleFingersEvent:(BOOL)val;
-(void)setDirection:(int)dir;
- (void)updateCurrentPos:(PositionObj*) p;
- (PositionObj*)getPositionFromPixel:(float)x andY:(float)y;
+ (void)getLatLonfromXY:(int)x andY:(int)y withXOffset:(int)xoff andYOffset:(int)yoff toLat:(float*)lat andLon:(float*)lon withZoom:(int)zoom;
+ (void)getXYfrom:(float)lat andLon:(float)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom;
- (void)getXYOffsetfrom:(float)lat andLon:(float)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2;
@end