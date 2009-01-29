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
#import "DirectionsController.h"
@interface MapView : UIView<LocationWrapperProtocol,ZoomingProtocol,TileDownloadProtocol> {
	//MapTile
	TileDB *db;
	PositionObj* pos;
	PositionObj* posGPS;
	PositionObj* posDrivingInstruction;
	NSMutableDictionary* tilescache;
	BOOL hasGPSfix;
	BOOL dragging;
	CGPoint lastDragPoint;
	int zoom;
	double prevDist;

	MapTile* imgPinRef;
	MapTile* imgPinSearch;
	MapTile* imgGoogleLogo;

	CGPoint drawOrigin;
	MapTile* tileNoMap;

	PositionObj *posSearch;

	BOOL lastInitMove;
	PositionObj *lastPos;
	double mapRotation;
	double gpsHeading;
	BOOL gpsTracking;
	BOOL mapRotationEnabled;
	ZoomView *assocZoomview;
	//int debugRoadStep;
	BOOL useGPSBall;
	CGPoint pDepForMapSelection;
	CGPoint pEndForMapSelection;
	BOOL nightMode;
	int maxZoom;
}
@property(retain,nonatomic) PositionObj *pos;
@property(nonatomic) CGPoint pDepForMapSelection;
@property(nonatomic) CGPoint pEndForMapSelection;
@property(nonatomic) BOOL mapRotationEnabled;
@property(nonatomic,assign) ZoomView *assocZoomview;
@property(nonatomic) BOOL nightMode;
@property(nonatomic) int maxZoom;
//@property(nonatomic) int debugRoadStep;
-(void)refreshMap;
-(void)fulllRefreshMap;
-(int)zoom;
-(void)computeCachedRoad;
-(id)initWithFrame:(CGRect)f withDB:(TileDB*)_db;
-(void)tileDownloaded;
-(void)setGPSTracking:(BOOL)val;
-(BOOL)hasGPSTracking;
-(void)setNextInstruction:(Instruction*)i updatePos:(BOOL)b;
-(void)setZoom:(int)z;
-(void)zoomin:(id)sender;
-(void)setDir:(id)d;
-(void)zoomout:(id)sender;
-(void)setPosSearch:(PositionObj*)p;
+(double)getMetersPerPixel:(double)latitude zoom:(int)zoom;
-(double)getMetersPerPixel:(double)latitude;
-(void)addDrawPoint:(PositionObj*)p;
-(PositionObj*)getCurrentPos;
- (void)setHasGPSPos:(BOOL)val;
- (void)updateCurrentPos:(PositionObj*) p;
- (PositionObj*)getPositionFromPixel:(double)x andY:(double)y;
+ (void)getLatLonfromXY:(int)x andY:(int)y withXOffset:(int)xoff andYOffset:(int)yoff toLat:(double*)lat andLon:(double*)lon withZoom:(int)zoom2;
- (void)getLatLonfromXY:(int)x andY:(int)y withXOffset:(int)xoff andYOffset:(int)yoff toLat:(double*)lat andLon:(double*)lon withZoom:(int)zoom2;
- (void)getXYfrom:(double)lat andLon:(double)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2;
- (void)getXYOffsetfrom:(double)lat andLon:(double)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2;
+ (void)getXYfrom:(double)lat andLon:(double)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2;
+ (void)getXYOffsetfrom:(double)lat andLon:(double)lon toPositionX:(int*)x andY:(int*)y withZoom:(int)zoom2;
@end