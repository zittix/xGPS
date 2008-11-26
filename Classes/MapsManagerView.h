//
//  MapsManagerView.h
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import "TileDB.h"
#import "ProgressView.h"
#import "ZoomView.h"

@protocol ShowMapProtocol
-(void) showMap;
@end

@interface MapsManagerView : UIViewController<UIAlertViewDelegate> {
	id delegate;
	MapView *mapview;
	TileDB *db;
	CGPoint pDep;
	CGPoint pEnd;
	int orientation;
	ProgressView *progress;
	BOOL downloading;
	ZoomView *zoomview;
	CGRect viewRect;
	UIToolbar *toolbar;
	UISegmentedControl* maptype;
}
-(void)clearSelection;
-(void)updateCurrentPos:(PositionObj*)pos;
-(id) initWithDB:(TileDB*)_db;

@end