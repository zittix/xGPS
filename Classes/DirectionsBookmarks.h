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
	sqlite3_stmt* insertRoadPointStmt;
	sqlite3_stmt* insertInstrStmt;
	sqlite3_stmt* insertBookmarkStmt;
	sqlite3_stmt* getBookmarkStmt;
	sqlite3_stmt* getRoadPointStmt;
	sqlite3_stmt* getInstrStmt;
	sqlite3_stmt* deleteRoadPointStmt;
	sqlite3_stmt* getOneBookmarkStmt;
	sqlite3_stmt* deleteInstrStmt;
	sqlite3_stmt* deleteBookmarkStmt;
	BOOL closed;
}
-(id)init;
-(void)close;
-(void)load;
-(NSString*)getDBFilename;
-(int)insertBookmark:(NSArray*)roadPoints withInstructions:(NSArray*)instr from:(NSString*)from via:(NSArray*)via to:(NSString*)to name:(NSString*)name;
-(NSArray*)copyBookmarks;
-(BOOL)getBookmarkInfo:(long)_id from:(NSString**)from to:(NSString**)to via:(NSArray**)via;
-(void)deleteBookmark:(long)_id;
-(void)deleteAllBookmarks;
-(NSMutableArray*)copyBookmarkRoadPoints:(int)id;
-(NSMutableArray*)copyBookmarkInstructions:(int)id;
@end
