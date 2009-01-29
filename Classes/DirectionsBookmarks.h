//
//  DirectionsBookmarks.h
//  xGPS
//
//  Created by Mathieu on 25.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DirectionsBookmarks : NSObject {
	sqlite3 *database;
	//sqlite3_stmt* getTileStmt;
	//sqlite3_stmt* checkTileStmt;
	sqlite3_stmt* insertRoadPointStmt;
	sqlite3_stmt* insertInstrStmt;
	sqlite3_stmt* insertBookmarkStmt;
	sqlite3_stmt* getBookmarkStmt;
	sqlite3_stmt* getRoadPointStmt;
	sqlite3_stmt* getInstrStmt;
	sqlite3_stmt* deleteRoadPointStmt;
	sqlite3_stmt* deleteInstrStmt;
	sqlite3_stmt* deleteBookmarkStmt;
	BOOL closed;
}
-(id)init;
-(int)insertBookmark:(NSArray*)roadPoints withInstructions:(NSArray*)instr from:(NSString*)from to:(NSString*)to;
-(NSArray*)copyBookmarks;
-(void)deleteBookmark:(long)_id;
-(void)deleteAllBookmarks;
-(NSMutableArray*)copyBookmarkRoadPoints:(int)id;
-(NSMutableArray*)copyBookmarkInstructions:(int)id;
@end
