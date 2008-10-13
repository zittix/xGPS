//
//  TileDB.h
//  xGPS
//
//  Created by Mathieu on 6/16/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "MapTile.h"
#import "ProgressView.h"

@protocol TileDownloadProtocol
-(void)tileDownloaded;
@end


@interface TileDB : NSObject {
	sqlite3 *database;
	sqlite3_stmt* getTileStmt;
	sqlite3_stmt* checkTileStmt;
	sqlite3_stmt* insertTileStmt;
	BOOL cancelDownload;
	NSMutableArray* tileHeap;
	NSLock *tileHeapLock;
	NSLock *dbLock;
	NSCondition *hasTileToDLlock;
	BOOL runAsync;
	BOOL offline;
	NSString *langMap;
	BOOL closed;
	int type;
}
-(MapTile*)getTile:(int)x atY:(int)y withZoom:(int)zoom withDelegate:(id)delegate;
-(BOOL)downloadTile:(int)x atY:(int)y withZoom:(int)zoom;
-(void)cancelDownload;
-(float)mapsize;
-(void)flushMaps;
-(void)closeDB;
-(void)loadDB;
-(int)downloadTiles:(int)fX fromY:(int)fY toX:(int)toX toY:(int)toY withZoom:(int)zoom  withDelegate:(ProgressView*)progress;
@end
