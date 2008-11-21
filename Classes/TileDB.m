//
//  TileDB.m
//  xGPS
//
//  Created by Mathieu on 6/16/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "TileDB.h"

#include <sqlite3.h>
#import "xGPSAppDelegate.h"
#import "Position.h"
#import "SyncDownloader.h"
@implementation TileDB

-(void)loadDB {
	//[dbLock lock];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xGPS_map.db"];
	NSFileManager * fm = [NSFileManager defaultManager];
	NSLog(@"Using Sqlite Version %s",sqlite3_libversion());
	//NSLog(@"Sqlite library thread-safe option: %@",(sqlite3_threadsafe() ? @"Yes" : @"No"));
	NSLog(@"Loading DB %@...",path);
	
	//Check DB version
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsDBVersion]<2 && [[NSUserDefaults standardUserDefaults] integerForKey:kSettingsDBVersion]>0) {
		if([fm fileExistsAtPath:path]) {
		UIAlertView * hotSheet = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"Maps data",@"Maps data title")
								  message:NSLocalizedString(@"Your downloaded maps are not compatible with this version of xGPS. They have been deleted.",@"")
								  delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss")
								  otherButtonTitles:nil];
		
		[hotSheet show];
		
				
		NSError *err;
		[fm removeItemAtPath:path error:&err];
		}
		[[NSUserDefaults standardUserDefaults]  setInteger:2 forKey:kSettingsDBVersion];
		
	}
	
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		//Check if table exist
		char *error;
		
		//IF NOT EXISTS doesn't exist on 1.1.4
		int ret=sqlite3_prepare(database,"SELECT img FROM tiles WHERE x=?1 AND y=?2 AND zoom=?3 AND type=?4",-1,&getTileStmt,NULL);
		if(ret!=SQLITE_OK) { //Create Table
			char *tMap="CREATE TABLE tiles (x INTEGER, y INTEGER,zoom INTEGER,type INTEGER, img BLOB, PRIMARY KEY(x,y,zoom,type))";
			ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
			NSAssert1(ret==SQLITE_OK, @"Failed to create database's tables with message '%s'.",error);
			
			ret=sqlite3_prepare(database,"SELECT img FROM tiles WHERE x=?1 AND y=?2 AND zoom=?3 AND type=?4",-1,&getTileStmt,NULL);
			NSAssert1(ret==SQLITE_OK, @"Failed to prepare get query with message '%s'.",sqlite3_errmsg(database));
		}
		
		//Migrate the DB if wrong Primary index
		
		//tMap="DELETE FROM tiles";
		//ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
		//NSAssert1(ret==SQLITE_OK, @"Failed to empty database's tables with message '%s'.",error);
		
		
		//PRepare the get query for speedup
		
		
		//PRepare the insert query for speedup
		ret=sqlite3_prepare(database,"INSERT INTO tiles (x,y,zoom,type,img) VALUES(?1,?2,?3,?4,?5)",-1,&insertTileStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare insert query with message '%s'.",sqlite3_errmsg(database));
		
		//PRepare the check query for speedup
		ret=sqlite3_prepare(database,"SELECT x FROM tiles WHERE x=?1 AND y=?2 AND zoom=?3 AND type=?4",-1,&checkTileStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare check query with message '%s'.",sqlite3_errmsg(database));
		
	} else {
		// Even though the open failed, call close to properly clean up resources.
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		// Additional error handling, as appropriate...
	}
	//[dbLock unlock];
	closed=NO;
}

-(id)init {
	closed=YES;
	tileHeap=[[NSMutableArray arrayWithCapacity:10] retain];
	tileHeapLock=[[NSLock alloc] init];
	tileHeapLock.name=@"TileHeapLock";
	dbLock=[[NSLock alloc] init];
	dbLock.name=@"DBLock";
	hasTileToDLlock=[[NSCondition alloc] init];
	hasTileToDLlock.name=@"hasTileToDLlock";
	runAsync=YES;
	offline=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline];
	langMap=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
	if(langMap!=nil)
		langMap=[langMap retain];
	type=0;
	[self loadDB];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlineModeChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
	[NSThread detachNewThreadSelector:@selector(asyncTileGet) toTarget:self withObject:nil];

	
	return self;
}
-(void)closeDB {
	if(closed) return;
	[dbLock lock];
	sqlite3_finalize(getTileStmt);
	sqlite3_finalize(insertTileStmt);
	sqlite3_finalize(checkTileStmt);
	sqlite3_close(database);
	[dbLock unlock];
	closed=YES;
}
-(void)offlineModeChanged:(NSNotification *)notif {
	//NSLog(@"Offline changed");
	offline=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline];
	if(langMap!=nil)
		[langMap release];
	langMap=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
	if(langMap!=nil)
		langMap=[langMap retain];
}
-(void) dealloc {
	runAsync=NO;
	if(langMap!=nil) {
		[langMap release];	
	}
	[hasTileToDLlock unlock];
	sqlite3_finalize(getTileStmt);
	sqlite3_finalize(insertTileStmt);
	sqlite3_finalize(checkTileStmt);
	sqlite3_close(database);
	[super dealloc];
}
-(void)cancelDownload {
	cancelDownload=YES;
}
-(void)flushMaps {
	if(closed) return;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xGPS_map.db"];
	
	NSFileManager * fm = [NSFileManager defaultManager];
	[dbLock lock];
	sqlite3_finalize(getTileStmt);
	sqlite3_finalize(insertTileStmt);
	sqlite3_finalize(checkTileStmt);
	sqlite3_close(database);
	
	NSError *err;
	[fm removeItemAtPath:path error:&err];
	
	
	[self loadDB];
	[dbLock unlock];
}

- (void)asyncTileGet {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Async Tile Get Thread - Started");
	//NSMutableArray *arrD=[NSMutableArray arrayWithCapacity:5];
	while(runAsync) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[hasTileToDLlock lock];
		[tileHeapLock lock];
		int nb=[tileHeap count];
		[tileHeapLock unlock];
		while(nb==0 || closed) {
			[hasTileToDLlock wait];
			[tileHeapLock lock];
			nb=[tileHeap count];
			[tileHeapLock unlock];	
		}
		[hasTileToDLlock unlock];
		[tileHeapLock lock];
		NSArray *copy=[tileHeap copy];
		[tileHeap removeAllObjects];
		[tileHeapLock unlock];
		[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
		
		for(int i=[copy count]-1;i>=0;i--) {
			TileCoord *p=[copy objectAtIndex:i];
			[dbLock lock];
			sqlite3_bind_int(checkTileStmt,1,p.x);
			sqlite3_bind_int(checkTileStmt,2,p.y);
			sqlite3_bind_int(checkTileStmt,3,p.zoom);
			sqlite3_bind_int(checkTileStmt,4,type);
			int r=sqlite3_step(checkTileStmt);
			sqlite3_reset(checkTileStmt);
			sqlite3_clear_bindings(checkTileStmt);
			[dbLock unlock];
			if (r != SQLITE_ROW) {
				if([self downloadTile:p.x atY:p.y withZoom:p.zoom]) {
					if(p.delegate!=nil) {
						[p.delegate performSelectorOnMainThread:@selector(tileDownloaded) withObject:nil waitUntilDone:NO];
					}
				}
			} else {
				if(p.delegate!=nil) {
					[p.delegate performSelectorOnMainThread:@selector(tileDownloaded) withObject:nil waitUntilDone:NO];
				}	
			}
		}
		
		[copy release];
		//[arrD removeAllObjects];
		[pool release];
		[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
	}
	
	NSLog(@"Async Tile Get Thread - Stoped");
	[pool release];
}

-(int)downloadTiles:(int)fX fromY:(int)fY toX:(int)toX toY:(int)toY withZoom:(int)zoom  withDelegate:(ProgressView*)progress{
	if(closed) return -1;
	int i,j;
	int ret=1;
	cancelDownload=NO;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	if(toY<fY)
	{
		int tmp=fY;
		fY=toY;
		toY=tmp;
	}
	if(toX<fX)
	{
		int tmp=fX;
		fX=toX;
		toX=tmp;
	}
	int nbToDownload=abs(toX-fX+1)*abs(toY-fY+1);
	NSLog(@"Downloading %d tiles...",nbToDownload);
	int nbDownloaded=1;
	
	
	int nbDownloadedTotal=0;
	for(i=fX;i<=toX;i++) {
		for(j=fY;j<=toY;j++) {
			NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
			if(cancelDownload) {
				[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
				NSLog(@"Canceled");
				[pool release];
				return -1;
			}
			[dbLock lock];
			sqlite3_bind_int(checkTileStmt,1,i);
			sqlite3_bind_int(checkTileStmt,2,j);
			sqlite3_bind_int(checkTileStmt,3,zoom);
			sqlite3_bind_int(checkTileStmt,4,type);
			int r=sqlite3_step(checkTileStmt);
			sqlite3_reset(checkTileStmt);
			sqlite3_clear_bindings(checkTileStmt);
			[dbLock unlock];
			if (r != SQLITE_ROW) {
				if(![self downloadTile:i atY:j withZoom:zoom]) {
					ret=0;
					
				} else {
					nbDownloaded++;
				}
				
			}
			nbDownloadedTotal++;
			float prc=((float)nbDownloadedTotal/(float)nbToDownload);
			//[progress setProgressObj:[NSNumber numberWithFloat:prc]];
			NSNumber *nb=[[NSNumber alloc] initWithFloat:prc];
			[progress performSelectorOnMainThread:@selector(setProgressObj:) withObject:nb waitUntilDone:YES];
			[nb release];
			//if(i*j%20==0) {
			//	NSLog(@"Download status: %f %%",prc*100.0);
			//}
			if(nbDownloaded%300==0 && !cancelDownload) {
				nbDownloaded=0;
				NSLog(@"Sleeping...");
				//[NSThread sleepUntilDate:[[NSDate date] addTimeInterval: 3]]; //Sleep 3s.. Google seems more happy :-)
				NSLog(@"Go to WORK !");
			}
			
			if(cancelDownload) {
				[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
				NSLog(@"Canceled");
				[pool release];
				return -1;
			}
			
			[pool release];
		}
	}
	NSLog(@"Tiles downloaded !");
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
	
	return ret;
}
-(MapTile*)getTile:(int)x atY:(int)y withZoom:(int)zoom  withDelegate:(id)delegate{
	if(closed) return nil;
	//NSLog(@"TileDB- getTile()- IN");
	if(x<0 || y<0) return nil;
	[dbLock lock];
	sqlite3_bind_int(getTileStmt,1,x);
	sqlite3_bind_int(getTileStmt,2,y);
	sqlite3_bind_int(getTileStmt,3,zoom);
	sqlite3_bind_int(getTileStmt,4,type);
	int r=sqlite3_step(getTileStmt);
	[dbLock unlock];
	MapTile *t=nil;
	if (r == SQLITE_ROW) {
		//NSLog(@"Tile got");
		[dbLock lock];
		const void *data=sqlite3_column_blob(getTileStmt, 0);
		int length=sqlite3_column_bytes(getTileStmt, 0);
		//NSLog(@"Tile of %d bytes",length);
		t=[[MapTile alloc] initWithData: [NSData dataWithBytes:data length:length]];
		sqlite3_reset(getTileStmt);
		sqlite3_clear_bindings(getTileStmt);
		[dbLock unlock];
	} else {
		[dbLock lock];
		sqlite3_reset(getTileStmt);
		sqlite3_clear_bindings(getTileStmt);
		[dbLock unlock];
		//NSLog(@"Downloading tile...");
		/*if(![self downloadTile:x atY:y withZoom:zoom]) {
		 NSLog(@"Unable to download tile !");
		 return nil;
		 } else {
		 t=[self getTile:x atY:y withZoom:zoom];
		 }*/
		[tileHeapLock lock];
		[tileHeap addObject:[TileCoord tileCoordWithX:x y:y zoom:zoom delegate:delegate]];
		[tileHeapLock unlock];
		[hasTileToDLlock broadcast];
	}
	return t;
	
}
-(float)mapsize {
	if(closed) return -1;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xGPS_map.db"];
	//NSLog(@"Getting file size %@",path);
	NSFileManager * fm = [NSFileManager defaultManager];
	
	NSDictionary *fattrs = [fm fileAttributesAtPath:path traverseLink:YES];
	NSNumber *nb=[fattrs objectForKey:NSFileSize];
	//NSLog(@"file size: %f",[nb unsignedLongLongValue]/1024.0/1024.0);
	return [nb unsignedLongLongValue]/1024.0/1024.0;	
}


-(BOOL)downloadTile:(int)x atY:(int)y withZoom:(int)zoom {
	if(offline || closed) return NO;
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	NSString *lang=langMap;
	if(lang==nil) lang=@"en";
	
	NSString *mapType=@"w2.88"; //Normal
	switch(type){
		case 0: mapType=@"w2.88"; break;
		case 1: mapType=@"w2t.88"; break; //Hybrid
		case 2: mapType=@"w2p.88"; break; //Satellite
	}
	//NSString *mapType=@"w2t.75"; //Hybrid
	//NSString *mapType=@"w2p.75"; //Sat
	//int zoom=0;
	NSString *url=[[NSString alloc] initWithFormat:@"http://mt%d.google.com/mt?v=%@&x=%d&y=%d&z=%d&hl=%@",(x+y)&3,mapType,x,y,17-zoom,lang];


	//NSLog(@"Getting tile at %@",url);
	NSURL *imageURL = [[NSURL alloc] initWithString:url];
	[url release];
	NSMutableURLRequest *urlReq=[[NSMutableURLRequest alloc] initWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30 ];
	[imageURL release];
	/*
	 GET /mt/v=w2.80&hl=en&x=0&y=0&zoom=15&s= HTTP/1.1
	 Host: mt0.google.com
	 User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1
	 Accept: image/png,image/*;q=0.8,**;q=0.5
	 Accept-Language: en-us,en;q=0.5
	 Accept-Encoding: gzip,deflate
	 Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
	 Keep-Alive: 300
	 Connection: keep-alive
	 Referer: http://maps.google.com/maps
	 Cookie: PREF=ID=6fe38e914f29d8bd:TM=1216826938:LM=1216826938:S=nHb12aTqCzjBVE5Q; SID=DQAAAHcAAADIzxH2zbbXeJtwYZKKQ8pg4X01CLuTyV0xykkDu7QvE1MdLHs-88fSNqZQO9YMBxRcDn3-O-Pc3iTTtu0GAeKhQX5DgCj-4nPDrPlAd0GdJw6lk1ZJebsJzQbGbT8hlnTsHch6kz6J5-Lt0gii3MWi09RqHTj_t-7qciC3-NjH_A; NID=13=ldPtTZQ7_bC01w2WqhpLM0zHNEY4CCTrXWePjNrfSYciNMhVYxXnbztKlxE5-h7ccjB5OiWWmp0UrOnlOwUTPjyaZIlgjkRQhPX6Z-_P-dlPn0zcQbEOFXxn3a-57Wzi
	 */	
	
	[urlReq setValue:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1" forHTTPHeaderField:@"User-Agent"];
	[urlReq setValue:@"image/png,image/*;q=0.8,*/*;q=0.5" forHTTPHeaderField:@"Accept"];
	[urlReq setValue:@"http://maps.google.com/maps" forHTTPHeaderField:@"Referer"];

	NSData *imageData=nil;
	
	SyncDownloader *dl=[[SyncDownloader alloc] init];
	
	BOOL res=[dl download:urlReq toData:&imageData];
	[urlReq release];
	
	
	if(imageData==nil || !res) {
		//NSLog(@"Download error");
		[dl release];
		[pool release];
		return NO;
	}
	//NSLog(@"Tile got at (%d bytes)!",[imageData length]);
	[dbLock lock];
	if(sqlite3_bind_int(insertTileStmt,1,x)!=SQLITE_OK)
		goto err;
	if(sqlite3_bind_int(insertTileStmt,2,y)!=SQLITE_OK)
		goto err;
	if(sqlite3_bind_int(insertTileStmt,3,zoom)!=SQLITE_OK)
		goto err;
	if(sqlite3_bind_int(insertTileStmt,4,type)!=SQLITE_OK)
		goto err;
	if(sqlite3_bind_blob(insertTileStmt, 5, [imageData bytes], [imageData length], SQLITE_STATIC)!=SQLITE_OK)
		goto err;
	
	int r=sqlite3_step(insertTileStmt);
	sqlite3_reset(insertTileStmt);
	sqlite3_clear_bindings(insertTileStmt);
	[dl release];
	[dbLock unlock];
	if(r!=SQLITE_DONE) {
		NSLog(@"Unable to insert tile (%d,%d): %s. Err. code=%d",x,y,sqlite3_errmsg(database),r);
		[pool release];
		return NO;
	}
	[pool release];
	//NSLog(@"Tile downloaded and saved !");
	return YES;
err:
	[dbLock unlock];
	[dl release];
	[pool release];
	NSLog(@"Error while getting tile.");
	sqlite3_reset(insertTileStmt);
	sqlite3_clear_bindings(insertTileStmt);

	return NO;
}
@end
