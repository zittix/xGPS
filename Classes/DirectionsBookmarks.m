//
//  DirectionsBookmarks.m
//  xGPS
//
//  Created by Mathieu on 25.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DirectionsBookmarks.h"
#import "xGPSAppDelegate.h"
#import "Position.h"
#import "DirectionsController.h"
#import "NavigationPoint.h"
@implementation DirectionsBookmarks

-(id)init {
	if((self=[super init])) {
		closed=YES;
		[self load];
	}
	return self;
}
-(void) load {
	if(!closed) return;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xGPS_directions.db"];
	NSFileManager * fm = [NSFileManager defaultManager];
	NSLog(@"Using Sqlite Version %s",sqlite3_libversion());
	//NSLog(@"Sqlite library thread-safe option: %@",(sqlite3_threadsafe() ? @"Yes" : @"No"));
	NSLog(@"Loading Direction Bookmarks DB %@...",path);
	
	//Check DB version
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsDirBookmarksDBVersion]<3 && [[NSUserDefaults standardUserDefaults] integerForKey:kSettingsDirBookmarksDBVersion]>0) {
		if([fm fileExistsAtPath:path]) {
			UIAlertView * hotSheet = [[UIAlertView alloc]
									  initWithTitle:NSLocalizedString(@"Directions Bookmarks",@"")
									  message:NSLocalizedString(@"Your saved driving directions are not compatible with this version of xGPS. They have been deleted.",@"")
									  delegate:nil
									  cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss")
									  otherButtonTitles:nil];
			
			[hotSheet show];
			
			
			NSError *err;
			[fm removeItemAtPath:path error:&err];
		}
		
		
	}
	[[NSUserDefaults standardUserDefaults]  setInteger:3 forKey:kSettingsDirBookmarksDBVersion];
	
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		char *error;
		int ret;
		char *tMap="CREATE TABLE IF NOT EXISTS dirbookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, fromPos TEXT,toPos TEXT,date INTEGER,length INTEGER,duration INTEGER, name TEXT, via TEXT)";
		ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
		NSAssert1(ret==SQLITE_OK, @"Failed to create database's tables with message '%s'.",error);
		tMap="CREATE TABLE IF NOT EXISTS dirb_roadpoints (lat REAL,lon REAL,owner INTEGER,internalId INTEGER)";
		ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
		NSAssert1(ret==SQLITE_OK, @"Failed to create database's tables with message '%s'.",error);
		tMap="CREATE TABLE IF NOT EXISTS dirb_instructions (lat REAL,lon REAL,owner INTEGER,internalId INTEGER,name TEXT,descr TEXT)";
		ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
		NSAssert1(ret==SQLITE_OK, @"Failed to create database's tables with message '%s'.",error);
		ret=sqlite3_prepare(database,"SELECT id,fromPos,toPos,date,name,via FROM dirbookmarks ORDER BY date DESC",-1,&getBookmarkStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare get query with message '%s'.",sqlite3_errmsg(database));
		
		ret=sqlite3_prepare(database,"SELECT lat,lon FROM dirb_roadpoints WHERE owner=?1 ORDER BY internalId ASC",-1,&getRoadPointStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare get query with message '%s'.",sqlite3_errmsg(database));
		
		ret=sqlite3_prepare(database,"SELECT lat,lon,name,descr FROM dirb_instructions WHERE owner=?1 ORDER BY internalId ASC",-1,&getInstrStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare get query with message '%s'.",sqlite3_errmsg(database));
		
		
		
		//Migrate the DB if wrong Primary index
		
		//tMap="DELETE FROM tiles";
		//ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
		//NSAssert1(ret==SQLITE_OK, @"Failed to empty database's tables with message '%s'.",error);
		
		
		//PRepare the get query for speedup
		
		
		//PRepare the insert query for speedup
		ret=sqlite3_prepare(database,"INSERT INTO dirb_roadpoints (lat,lon,owner,internalId) VALUES(?1,?2,?3,?4)",-1,&insertRoadPointStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare insert query with message '%s'.",sqlite3_errmsg(database));
		ret=sqlite3_prepare(database,"INSERT INTO dirb_instructions (lat,lon,owner,internalId,name,descr) VALUES(?1,?2,?3,?4,?5,?6)",-1,&insertInstrStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare insert query with message '%s'.",sqlite3_errmsg(database));
		ret=sqlite3_prepare(database,"INSERT INTO dirbookmarks (fromPos,toPos,date,name,via) VALUES(?1,?2,?3,?4,?5)",-1,&insertBookmarkStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare insert query with message '%s'.",sqlite3_errmsg(database));
		ret=sqlite3_prepare(database,"DELETE FROM dirbookmarks WHERE id=?1",-1,&deleteBookmarkStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare insert query with message '%s'.",sqlite3_errmsg(database));
		ret=sqlite3_prepare(database,"DELETE FROM dirb_roadpoints WHERE owner=?1",-1,&deleteRoadPointStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare insert query with message '%s'.",sqlite3_errmsg(database));
		ret=sqlite3_prepare(database,"DELETE FROM dirb_instructions WHERE owner=?1",-1,&deleteInstrStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare insert query with message '%s'.",sqlite3_errmsg(database));
		
		//PRepare the check query for speedup
		//ret=sqlite3_prepare(database,"SELECT x FROM tiles WHERE x=?1 AND y=?2 AND zoom=?3 AND type=?4",-1,&checkTileStmt,NULL);
		//NSAssert1(ret==SQLITE_OK, @"Failed to prepare check query with message '%s'.",sqlite3_errmsg(database));
		
	} else {
		// Even though the open failed, call close to properly clean up resources.
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		// Additional error handling, as appropriate...
		[self release];
		return;
	}
	closed=NO;
	

}
-(NSString*)getDBFilename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xGPS_directions.db"];
	return path;
}
-(void)close {
	if(closed) return;

	
	sqlite3_finalize(insertRoadPointStmt);
	sqlite3_finalize(insertInstrStmt);
	sqlite3_finalize(insertBookmarkStmt);
	sqlite3_finalize(getBookmarkStmt);
	sqlite3_finalize(getRoadPointStmt);
	sqlite3_finalize(getInstrStmt);
	sqlite3_finalize(deleteRoadPointStmt);
	sqlite3_finalize(deleteInstrStmt);
	sqlite3_finalize(deleteBookmarkStmt);
	
	sqlite3_close(database);
	closed=YES;
	
}
-(void)deleteAllBookmarks {
	if(closed) return;
	char *error;
	int ret;
	char *tMap="DELETE FROM dirbookmarks";
	ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
	tMap="DELETE FROM dirb_roadpoints";
	ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
	tMap="DELETE FROM dirb_instructions";
	ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
}
-(void)deleteBookmark:(long)_id {
	if(closed) return;
	if(sqlite3_bind_int64(deleteBookmarkStmt,1,_id)!=SQLITE_OK)
		goto err;
	
	int r=sqlite3_step(deleteBookmarkStmt);
	sqlite3_reset(deleteBookmarkStmt);
	sqlite3_clear_bindings(deleteBookmarkStmt);
	
	if(r!=SQLITE_DONE) {
		NSLog(@"Unable to delete bookmark: %s. Err. code=%d",sqlite3_errmsg(database),r);
		return;
	}
	if(sqlite3_bind_int64(deleteRoadPointStmt,1,_id)!=SQLITE_OK)
		goto err;
	
	r=sqlite3_step(deleteRoadPointStmt);
	sqlite3_reset(deleteRoadPointStmt);
	sqlite3_clear_bindings(deleteRoadPointStmt);
	
	if(r!=SQLITE_DONE) {
		NSLog(@"Unable to delete bookmark: %s. Err. code=%d",sqlite3_errmsg(database),r);
		return;
	}
	if(sqlite3_bind_int64(deleteInstrStmt,1,_id)!=SQLITE_OK)
		goto err;
	
	r=sqlite3_step(deleteInstrStmt);
	sqlite3_reset(deleteInstrStmt);
	sqlite3_clear_bindings(deleteInstrStmt);
	
	if(r!=SQLITE_DONE) {
		NSLog(@"Unable to delete bookmark: %s. Err. code=%d",sqlite3_errmsg(database),r);
		return;
	}
err:
	sqlite3_reset(deleteRoadPointStmt);
	sqlite3_clear_bindings(deleteRoadPointStmt);
	sqlite3_reset(deleteBookmarkStmt);
	sqlite3_clear_bindings(deleteBookmarkStmt);
	sqlite3_reset(deleteInstrStmt);
	sqlite3_clear_bindings(deleteInstrStmt);
}

-(NSMutableArray*)copyBookmarkRoadPoints:(int)id{
	if(closed) return nil;
	NSMutableArray *ret=[[NSMutableArray alloc] initWithCapacity:5];
	if(sqlite3_bind_int64(getRoadPointStmt,1,id)!=SQLITE_OK)
		goto err;
	
	int r=sqlite3_step(getRoadPointStmt);
	while (r == SQLITE_ROW) {
		double lat =sqlite3_column_double(getRoadPointStmt,0);
		double lon =sqlite3_column_double(getRoadPointStmt,1);
		PositionObj *p=[PositionObj positionWithX:lat y:lon];
		//NSLog(@"Point %f %f",lat,lon);
		[ret addObject:p];
		r=sqlite3_step(getRoadPointStmt);
	}
	sqlite3_reset(getRoadPointStmt);
	sqlite3_clear_bindings(getRoadPointStmt);
	return ret;
err:
	sqlite3_reset(getRoadPointStmt);
	sqlite3_clear_bindings(getRoadPointStmt);
	return nil;
}
-(NSMutableArray*)copyBookmarkInstructions:(int)id {
	if(closed) return nil;
	NSMutableArray *ret=[[NSMutableArray alloc] initWithCapacity:5];
	if(sqlite3_bind_int64(getInstrStmt,1,id)!=SQLITE_OK)
		goto err;
	
	int r=sqlite3_step(getInstrStmt);
	while (r == SQLITE_ROW) {
		double lat =sqlite3_column_double(getInstrStmt,0);
		double lon =sqlite3_column_double(getInstrStmt,1);
		const char* nameC=(const char*)sqlite3_column_text(getInstrStmt,2);
		const char* descrC=(const char*)sqlite3_column_text(getInstrStmt,3);
		if(nameC!=NULL) {
			NSString *name=[[NSString alloc] initWithCString:nameC encoding:NSUTF8StringEncoding];
			
		NSString *descr=nil;
			if(descrC!=NULL)
				descr=[[NSString alloc] initWithCString:descrC encoding:NSUTF8StringEncoding];
			else
				descr=@"";
			
		PositionObj *p=[PositionObj positionWithX:lat y:lon];
		Instruction *r2=[Instruction instrWithName:name pos:p descr:descr];
		[name release];
		[descr release];
		[ret addObject:r2];
		}
		r=sqlite3_step(getInstrStmt);
	}
	sqlite3_reset(getInstrStmt);
	sqlite3_clear_bindings(getInstrStmt);
	return ret;
err:
	sqlite3_reset(getInstrStmt);
	sqlite3_clear_bindings(getInstrStmt);	
	return nil;
}


-(NSArray*)copyBookmarks{
	if(closed) return nil;
	NSMutableArray *ret=[[NSMutableArray alloc] initWithCapacity:5];
	int r=sqlite3_step(getBookmarkStmt);
	while (r == SQLITE_ROW) {
		long id=sqlite3_column_int64(getBookmarkStmt, 0);
		int date=sqlite3_column_int(getBookmarkStmt, 3);
		NSString *from=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(getBookmarkStmt,1) encoding:NSUTF8StringEncoding];
		NSString *to=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(getBookmarkStmt,2) encoding:NSUTF8StringEncoding];
		NSString *name=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(getBookmarkStmt,4) encoding:NSUTF8StringEncoding];
		NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:id],@"id",[NSNumber numberWithInt:date],@"date",from,@"from",to,@"to",name,@"name",nil];
		[ret addObject:dict];
		[to release];
		[from release];
		[name release];
		from=nil;
		to=nil;
		name=nil;
		r=sqlite3_step(getBookmarkStmt);
	}
		sqlite3_reset(getBookmarkStmt);
		sqlite3_clear_bindings(getBookmarkStmt);

	
	return ret;
}
-(int)insertBookmark:(NSArray*)roadPoints withInstructions:(NSArray*)instr from:(NSString*)from via:(NSArray*)via to:(NSString*)to name:(NSString*)name {
	if(closed) return -1;
	//First insert the bookmark
	int date=[[NSDate date] timeIntervalSince1970];
	if(sqlite3_bind_text(insertBookmarkStmt,1,[from UTF8String],-1, SQLITE_STATIC)!=SQLITE_OK)
		goto err;
	if(sqlite3_bind_text(insertBookmarkStmt,2,[to UTF8String],-1, SQLITE_STATIC)!=SQLITE_OK)
		goto err;
	if(sqlite3_bind_int(insertBookmarkStmt,3,date)!=SQLITE_OK)
		goto err;
	if(sqlite3_bind_text(insertBookmarkStmt,4,[name UTF8String],-1, SQLITE_STATIC)!=SQLITE_OK)
		goto err;
	
	NSString *viaText=@"";
	if(via!=nil) {
		for(NavigationPoint *p in via) {
			viaText=[NSString stringWithFormat:@"%@|%f,%f;",p.name,p.pos.x,p.pos.y];
		}
		if([viaText hasSuffix:@";"]) {
			viaText=[viaText substringToIndex:viaText.length -1];
		}
		NSLog(@"Via text: %@",viaText);
	}
	if(sqlite3_bind_text(insertBookmarkStmt,5,[viaText UTF8String],-1, SQLITE_STATIC)!=SQLITE_OK)
		goto err;

	int r=sqlite3_step(insertBookmarkStmt);
	sqlite3_reset(insertBookmarkStmt);
	sqlite3_clear_bindings(insertBookmarkStmt);

	if(r!=SQLITE_DONE) {
		NSLog(@"Unable to insert bookmark: %s. Err. code=%d",sqlite3_errmsg(database),r);
		return -1;
	}

	//Get bookmark id
	long id=sqlite3_last_insert_rowid(database);
	for(int i=0;i<[roadPoints count];i++) {
		PositionObj *p=[roadPoints objectAtIndex:i];
		if(sqlite3_bind_double(insertRoadPointStmt,1,p.x)!=SQLITE_OK)
			goto err;
		if(sqlite3_bind_double(insertRoadPointStmt,2,p.y)!=SQLITE_OK)
			goto err;
		if(sqlite3_bind_int64(insertRoadPointStmt,3,id)!=SQLITE_OK)
			goto err;
		if(sqlite3_bind_int(insertRoadPointStmt,4,i)!=SQLITE_OK)
			goto err;
		int r=sqlite3_step(insertRoadPointStmt);
		sqlite3_reset(insertRoadPointStmt);
		sqlite3_clear_bindings(insertRoadPointStmt);
		
		if(r!=SQLITE_DONE) {
			NSLog(@"Unable to insert roadpoints: %s. Err. code=%d",sqlite3_errmsg(database),r);
			return -1;
		}
		
	}
	for(int i=0;i<[instr count];i++) {
		Instruction *in=[instr objectAtIndex:i];
		if(sqlite3_bind_double(insertInstrStmt,1,in.pos.x)!=SQLITE_OK)
			goto err;
		if(sqlite3_bind_double(insertInstrStmt,2,in.pos.y)!=SQLITE_OK)
			goto err;
		if(sqlite3_bind_int64(insertInstrStmt,3,id)!=SQLITE_OK)
			goto err;
		if(sqlite3_bind_int(insertInstrStmt,4,i)!=SQLITE_OK)
			goto err;
		if(sqlite3_bind_text(insertInstrStmt,5,[in.name UTF8String],-1, SQLITE_STATIC)!=SQLITE_OK)
			goto err;
		if(sqlite3_bind_text(insertInstrStmt,6,[in.descr UTF8String],-1, SQLITE_STATIC)!=SQLITE_OK)
			goto err;
		int r=sqlite3_step(insertInstrStmt);
		sqlite3_reset(insertInstrStmt);
		sqlite3_clear_bindings(insertInstrStmt);
		
		if(r!=SQLITE_DONE) {
			NSLog(@"Unable to insert instruction: %s. Err. code=%d",sqlite3_errmsg(database),r);
			return -1;
		}
		
	}

	return id;

err:
	sqlite3_reset(insertRoadPointStmt);
	sqlite3_clear_bindings(insertRoadPointStmt);
	sqlite3_reset(insertInstrStmt);
	sqlite3_clear_bindings(insertInstrStmt);
	sqlite3_reset(insertBookmarkStmt);
	sqlite3_clear_bindings(insertBookmarkStmt);
	return -1;
}
@end
