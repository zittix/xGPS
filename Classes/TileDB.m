//
//  TileDB.m
//  xGPS
//
//  Created by Mathieu on 6/16/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "TileDB.h"

#include <sqlite3.h>

@implementation TileDB

-(void)loadDB {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xGPS_map.db"];
	NSLog(@"Using Sqlite Version %s",sqlite3_libversion());
	NSLog(@"Loading DB %@...",path);
	
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		//Check if table exist
		char *error;
		
		//IF NOT EXISTS doesn't exist on 1.1.4
		int ret=sqlite3_prepare(database,"SELECT img FROM tiles WHERE x=?1 AND y=?2 AND zoom=?3",-1,&getTileStmt,NULL);
		if(ret!=SQLITE_OK) { //Create Table
			char *tMap="CREATE TABLE tiles (x INTEGER, y INTEGER,zoom INTEGER,type INTEGER, img BLOB, PRIMARY KEY(x,y,zoom))";
			ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
			NSAssert1(ret==SQLITE_OK, @"Failed to create database's tables with message '%s'.",error);
			
			ret=sqlite3_prepare(database,"SELECT img FROM tiles WHERE x=?1 AND y=?2 AND zoom=?3",-1,&getTileStmt,NULL);
			NSAssert1(ret==SQLITE_OK, @"Failed to prepare get query with message '%s'.",sqlite3_errmsg(database));
		}
		
		//tMap="DELETE FROM tiles";
		//ret= sqlite3_exec(database,tMap,NULL,NULL,&error);
		//NSAssert1(ret==SQLITE_OK, @"Failed to empty database's tables with message '%s'.",error);
		
		
		//PRepare the get query for speedup
		
		
		//PRepare the insert query for speedup
		ret=sqlite3_prepare(database,"INSERT INTO tiles (x,y,zoom,type,img) VALUES(?1,?2,?3,0,?4)",-1,&insertTileStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare insert query with message '%s'.",sqlite3_errmsg(database));
		
		//PRepare the check query for speedup
		ret=sqlite3_prepare(database,"SELECT x FROM tiles WHERE x=?1 AND y=?2 AND zoom=?3",-1,&checkTileStmt,NULL);
		NSAssert1(ret==SQLITE_OK, @"Failed to prepare check query with message '%s'.",sqlite3_errmsg(database));
		
	} else {
		// Even though the open failed, call close to properly clean up resources.
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		// Additional error handling, as appropriate...
	}
}

-(id)init {

		// Open the database. The database was prepared outside the application.
	[self loadDB];
	return self;
}

-(void) dealloc {
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
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xGPS_map.db"];

	NSFileManager * fm = [NSFileManager defaultManager];
	
	sqlite3_finalize(getTileStmt);
	sqlite3_finalize(insertTileStmt);
	sqlite3_finalize(checkTileStmt);
	sqlite3_close(database);
	NSError *err;
	if( [fm removeItemAtPath:path error:&err]) {
	
	}
	[self loadDB];
	
}
-(int)downloadTiles:(int)fX fromY:(int)fY toX:(int)toX toY:(int)toY withZoom:(int)zoom  withDelegate:(ProgressView*)progress{
	int i,j;
	int ret=1;
	cancelDownload=NO;
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
	for(i=fX;i<=toX;i++)
	for(j=fY;j<=toY;j++) {
		if(cancelDownload) {
			return -1;
		}
		sqlite3_bind_int(checkTileStmt,1,i);
		sqlite3_bind_int(checkTileStmt,2,j);
		sqlite3_bind_int(checkTileStmt,3,zoom);
		int r=sqlite3_step(checkTileStmt);
		sqlite3_reset(checkTileStmt);
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
		[progress performSelectorOnMainThread:@selector(setProgressObj:) withObject:[NSNumber numberWithFloat:prc] waitUntilDone:YES];

		//if(i*j%20==0) {
		//	NSLog(@"Download status: %f %%",prc*100.0);
		//}
		if(nbDownloaded%100==0 && !cancelDownload) {
			nbDownloaded=0;
			NSLog(@"Sleeping...");
			[NSThread sleepUntilDate:[[NSDate date] addTimeInterval: 3]]; //Sleep 3s.. Google seems more happy :-)
			NSLog(@"Go to WORK !");
		}
	}
	//NSLog(@"Tiles downloaded !");
	return ret;
}
-(MapTile*)getTile:(int)x atY:(int)y withZoom:(int)zoom {
	//NSLog(@"TileDB- getTile()- IN");
	if(x<0 || y<0) return nil;

	sqlite3_bind_int(getTileStmt,1,x);
	sqlite3_bind_int(getTileStmt,2,y);
	sqlite3_bind_int(getTileStmt,3,zoom);
	int r=sqlite3_step(getTileStmt);
	MapTile *t;
	if (r == SQLITE_ROW) {
		//NSLog(@"Tile got");
		const void *data=sqlite3_column_blob(getTileStmt, 0);
		int length=sqlite3_column_bytes(getTileStmt, 0);
		//NSLog(@"Tile of %d bytes",length);
		t=[[MapTile alloc] initWithData: [NSData dataWithBytes:data length:length]];
		sqlite3_reset(getTileStmt);
	} else {
		sqlite3_reset(getTileStmt);
		//NSLog(@"Downloading tile...");
		if(![self downloadTile:x atY:y withZoom:zoom]) {
			NSLog(@"Unable to download tile !");
			return nil;
		} else {
			t=[self getTile:x atY:y withZoom:zoom];
		}
	}
	return t;

}
-(float)mapsize {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xGPS_map.db"];
	NSLog(@"Getting file size %@",path);
	NSFileManager * fm = [NSFileManager defaultManager];
	
	NSDictionary *fattrs = [fm fileAttributesAtPath:path traverseLink:YES];
	NSNumber *nb=[fattrs objectForKey:NSFileSize];
	NSLog(@"file size: %f",[nb unsignedLongLongValue]/1024.0/1024.0);
	return [nb unsignedLongLongValue]/1024.0/1024.0;	
}


-(BOOL)downloadTile:(int)x atY:(int)y withZoom:(int)zoom {
	NSString *mapType=@"w2.83"; //Normal
	//NSString *mapType=@"w2t.75"; //Hybrid
	//NSString *mapType=@"w2p.75"; //Sat
	//int zoom=0;
	NSString *url=[[NSString alloc] initWithFormat:@"http://mt%d.google.com/mt?n=404&v=%@&x=%d&y=%d&zoom=%d&hl=en",(x+y)&3,mapType,x,y,zoom];
	//NSString *url=@"http://mt0.google.com/mt?n=404&v=w2.75&hl=en&x=67918&s=&y=46321&zoom=0";
	//NSLog(@"Getting tile at %@",url);
	NSURL *imageURL = [NSURL URLWithString:url];
	NSMutableURLRequest *urlReq=[NSMutableURLRequest requestWithURL:imageURL];
	
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
	
	NSHTTPURLResponse *rep;
	NSData *imageData = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&rep error:NULL];
	[url release];

	if(imageData==nil || [imageData length]==0 || [rep statusCode]!=200) {
		NSLog(@"Download error: Rep code: %d",[rep statusCode]);
		return NO;
	}
	//NSLog(@"Tile got at (%d bytes)!",[imageData length]);
	if(sqlite3_bind_int(insertTileStmt,1,x)!=SQLITE_OK)
	goto err;
	if(sqlite3_bind_int(insertTileStmt,2,y)!=SQLITE_OK)
	goto err;
	if(sqlite3_bind_int(insertTileStmt,3,zoom)!=SQLITE_OK)
	goto err;
	if(sqlite3_bind_blob(insertTileStmt, 4, [imageData bytes], [imageData length], SQLITE_STATIC)!=SQLITE_OK)
	goto err;

	int r=sqlite3_step(insertTileStmt);
	sqlite3_reset(insertTileStmt);
	if(r!=SQLITE_DONE) {
		NSLog(@"Unable to insert tile (%d,%d): %s. Err. code=%d",x,y,sqlite3_errmsg(database),r);
		return NO;
	}

	//NSLog(@"Tile downloaded and saved !");
	return YES;
	err:
	NSLog(@"Error while getting tile.");
	sqlite3_reset(insertTileStmt);
	return NO;
}
@end
