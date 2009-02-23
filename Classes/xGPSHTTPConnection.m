//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//
#ifdef HAS_HTTPSERVER
#import "xGPSHTTPConnection.h"
#import "HTTPServer.h"
#import "HTTPResponse.h"
#import "xGPSAppDelegate.h"
#import <sys/stat.h>
static BOOL uploading=NO;
@implementation xGPSHTTPConnection

/**
 * Returns whether or not the requested resource is browseable.
 **/
- (BOOL)isBrowseable:(NSString *)path
{
	// Override me to provide custom configuration...
	// You can configure it for the entire server, or based on the current request
	
	return NO;
}

/**
 * This method creates a html browseable page.
 * Customize to fit your needs
 **/
- (NSString *) createBrowseableIndex:(NSString *)path
{
	// NSArray *array = [[NSFileManager defaultManager] directoryContentsAtPath:path];
    
    NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
	[outdata appendFormat:@"<title>%@</title>", NSLocalizedString(@"xGPS Web-based Management",@"")];
    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
	[outdata appendFormat:@"<h1>%@</h1>", NSLocalizedString(@"xGPS Web-based Management",@"")];
    [outdata appendFormat:@"<bq>%@</bq>",NSLocalizedString(@"Available actions:",@"")];
	[outdata appendString:@"<ul>"];
	[outdata appendFormat:@"<li><a href=\"/info\">%@</a></li>\n",NSLocalizedString(@"Show device info",@"")];
	[outdata appendFormat:@"<li><a href=\"/gpxlogger\">%@</a></li>\n",NSLocalizedString(@"GPX Log Files",@"")];
	[outdata appendFormat:@"<li><a href=\"/uploadMapsDB\">%@</a></li>\n",NSLocalizedString(@"Upload a new maps database",@"")];
	[outdata appendFormat:@"<li><a href=\"/uploadDirectionsDB\">%@</a></li>\n",NSLocalizedString(@"Upload a new directions database",@"")];
	[outdata appendString:@"</ul>"];
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
}
-(NSString*)createGPXLogFiles {
	NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
	[outdata appendFormat:@"<title>%@ - %@</title>", NSLocalizedString(@"xGPS Web-based Management",@""), NSLocalizedString(@"GPX Log Files",@"")];
    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
	[outdata appendFormat:@"<h1>%@</h1>", NSLocalizedString(@"GPX Log Files",@"")];
	[outdata appendString:@"<ul>"];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xgps_gpx"];
	
	NSArray *files=[[NSFileManager defaultManager] directoryContentsAtPath:path];
	
	for(NSString * f in files) {
		[outdata appendFormat:@"<li><a href=\"/api/getGPXLogFile/%@\">%@</a></li>\n",f,f];
		
	}
	
	
	[outdata appendString:@"</ul>"];
	[outdata appendFormat:@"<p><a href=\"/\">%@</a></p>",NSLocalizedString(@"Return to main page",@"")];
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
	
}
-(NSString*)createInfoPage {
	NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
	[outdata appendFormat:@"<title>%@ - %@</title>", NSLocalizedString(@"xGPS Web-based Management",@""), NSLocalizedString(@"Device Info",@"")];
    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
	[outdata appendFormat:@"<h1>%@</h1>", NSLocalizedString(@"Device Info",@"")];
	[outdata appendString:@"<ul>"];
	[outdata appendFormat:@"<li>%@: %@</li>\n",NSLocalizedString(@"xGPS Version",@""),@VERSION];
	[outdata appendFormat:@"<li>%@: %.1f MB</li>\n",NSLocalizedString(@"Map Database size",@""),[xGPSAppDelegate tiledb].mapsize ];
	[outdata appendString:@"</ul>"];
	[outdata appendFormat:@"<p><a href=\"/\">%@</a></p>",NSLocalizedString(@"Return to main page",@"")];
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
	
}
-(NSString*)createUploadOKPage {
	NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
	[outdata appendFormat:@"<title>%@ - %@</title>", NSLocalizedString(@"xGPS Web-based Management",@""), NSLocalizedString(@"Upload new maps database",@"")];
    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
	[outdata appendFormat:@"<h1>%@</h1>", NSLocalizedString(@"Upload new maps database",@"")];
	
	[outdata appendFormat:@"<p>%@</p>",NSLocalizedString(@"The maps database has been sucessfully saved.",@"")];
	[outdata appendFormat:@"<p><a href=\"/\">%@</a></p>",NSLocalizedString(@"Return to main page",@"")];
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
	
}

-(NSString*)createUploadDirectionsOKPage {
	NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
	[outdata appendFormat:@"<title>%@ - %@</title>", NSLocalizedString(@"xGPS Web-based Management",@""), NSLocalizedString(@"Upload new directions database",@"")];
    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
	[outdata appendFormat:@"<h1>%@</h1>", NSLocalizedString(@"Upload new directions database",@"")];
	
	[outdata appendFormat:@"<p>%@</p>",NSLocalizedString(@"The directions database has been sucessfully saved.",@"")];
	[outdata appendFormat:@"<p><a href=\"/\">%@</a></p>",NSLocalizedString(@"Return to main page",@"")];
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
	
}
-(NSString*)createUploadMapDBPage {
	NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
	[outdata appendFormat:@"<title>%@ - %@</title>", NSLocalizedString(@"xGPS Web-based Management",@""), NSLocalizedString(@"Upload new maps database",@"")];
    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
	[outdata appendFormat:@"<h1>%@</h1>", NSLocalizedString(@"Upload new maps database",@"")];
	
	[outdata appendString:@"<form action=\"/uploadMapsDB\" method=\"post\" enctype=\"multipart/form-data\" name=\"uplaodMapDB\" id=\"uplaodMapDB\">"];
	[outdata appendFormat:@"<label>%@ ",NSLocalizedString(@"New maps database: ",@"")];
	[outdata appendString:@"<input type=\"file\" name=\"file\" id=\"file\" />"];
	[outdata appendString:@"</label>"];
	[outdata appendString:@"<label>"];
	[outdata appendString:@"<input type=\"submit\" name=\"button\" id=\"button\" value=\"Upload\" />"];
	[outdata appendString:@"</label>"];
	[outdata appendString:@"</form>"];
	[outdata appendFormat:@"<p><a href=\"/\">%@</a></p>",NSLocalizedString(@"Return to main page",@"")];
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
	
}
-(NSString*)createUploadDirectionsDBPage {
	NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
	[outdata appendFormat:@"<title>%@ - %@</title>", NSLocalizedString(@"xGPS Web-based Management",@""), NSLocalizedString(@"Upload new directions database",@"")];
    [outdata appendString:@"<style>html {background-color:#eeeeee} body { background-color:#FFFFFF; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:18x; margin-left:15%; margin-right:15%; border:3px groove #006600; padding:15px; } </style>"];
    [outdata appendString:@"</head><body>"];
	[outdata appendFormat:@"<h1>%@</h1>", NSLocalizedString(@"Upload new directions database",@"")];
	
	[outdata appendString:@"<form action=\"/uploadDirectionsDB\" method=\"post\" enctype=\"multipart/form-data\" name=\"uploadDirectionsDB\" id=\"uploadDirectionsDB\">"];
	[outdata appendFormat:@"<label>%@ ",NSLocalizedString(@"New directions database: ",@"")];
	[outdata appendString:@"<input type=\"file\" name=\"file\" id=\"file\" />"];
	[outdata appendString:@"</label>"];
	[outdata appendString:@"<label>"];
	[outdata appendString:@"<input type=\"submit\" name=\"button\" id=\"button\" value=\"Upload\" />"];
	[outdata appendString:@"</label>"];
	[outdata appendString:@"</form>"];
	[outdata appendFormat:@"<p><a href=\"/\">%@</a></p>",NSLocalizedString(@"Return to main page",@"")];
	
	[outdata appendString:@"</body></html>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
	
}
-(NSString*)createAPI_dbUploadOK {
	NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<?xml version=\"1.0\"?>\n<xgpsAPI>"];
	[outdata appendFormat:@"<deviceID>%@</deviceID>", [UIDevice currentDevice].uniqueIdentifier];
	[outdata appendString:@"<version>"VERSION"</version>"];
	[outdata appendFormat:@"<status>ok</status>"];
	[outdata appendString:@"</xgpsAPI>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
	
}

-(NSString*)createAPI_info {
	NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<?xml version=\"1.0\"?>\n<xgpsAPI>"];
	[outdata appendFormat:@"<deviceID>%@</deviceID>", [UIDevice currentDevice].uniqueIdentifier];
	[outdata appendString:@"<version>"VERSION"</version>"];
	[outdata appendFormat:@"<name>%@</name>",[APPDELEGATE.txcontroller.httpServer publishedName]];
	[outdata appendFormat:@"<tiledbsize>%.2f</tiledbsize>",[APPDELEGATE.tiledb mapsize]];
	[outdata appendString:@"</xgpsAPI>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
	
}
-(NSString*)createAPI_GPXLogFiles {
	NSMutableString *outdata = [NSMutableString new];
	[outdata appendString:@"<?xml version=\"1.0\"?>\n<xgpsAPI>"];
	[outdata appendFormat:@"<deviceID>%@</deviceID>", [UIDevice currentDevice].uniqueIdentifier];
	[outdata appendString:@"<version>"VERSION"</version><gpxfiles>"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xgps_gpx"];
	
	NSArray *files=[[NSFileManager defaultManager] directoryContentsAtPath:path];
	
	for(NSString * f in files) {
		[outdata appendFormat:@"<file>%@</file>\n",f];
		
	}
	[outdata appendString:@"</gpxfiles>"];
	[outdata appendString:@"</xgpsAPI>"];
    
	//NSLog(@"outData: %@", outdata);
    return [outdata autorelease];
	
}


/**
 * Returns whether or not the server will accept POSTs.
 * That is, whether the server will accept uploaded data for the given URI.
 **/
- (BOOL)supportsPOST:(NSString *)path withSize:(UInt64)contentLength
{
	//NSLog(@"POST:%@", path);
	if(([path hasPrefix:@"/uploadMapsDB"] || [path hasPrefix:@"/uploadDirectionsDB"]) && !uploading) {
		dataStartIndex = 0;
		multipartData = [[NSMutableArray alloc] init];
		postHeaderOK = FALSE;
		if([path hasPrefix:@"/uploadMapsDB"])
			fileSaving=[[APPDELEGATE.tiledb getDBFilename] retain];
		else
			fileSaving=[[APPDELEGATE.dirbookmarks getDBFilename] retain];
		
		
		//NSLog(@"POST:%@", fileSaving);
		return YES;
	} else
		return NO;
}


/**
 * This method is called to get a response for a request.
 * You may return any object that adopts the HTTPResponse protocol.
 * The HTTPServer comes with two such classes: HTTPFileResponse and HTTPDataResponse.
 * HTTPFileResponse is a wrapper for an NSFileHandle object, and is the preferred way to send a file response.
 * HTTPDataResopnse is a wrapper for an NSData object, and may be used to send a custom response.
 **/
- (NSObject<HTTPResponse> *)httpResponseForURI:(NSString *)path
{
	NSLog(@"httpResponseForURI: %@", path);
	
	if([path isEqualToString:@"/info"]) {
		NSString *page=[self createInfoPage];
		NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
		HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
		return resp;
	} else if([path hasPrefix:@"/uploadMapsDB"]) {
		
		if (postContentLength > 0)		//process POST data
		{
			//NSLog(@"processing post data: %i", postContentLength);
			
			NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes] length:[[multipartData objectAtIndex:1] length] encoding:NSUTF8StringEncoding];
			NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
			postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
			postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
			NSString* filename = [postInfoComponents lastObject];
			
			if (![filename isEqualToString:@""]) //this makes sure we did not submitted upload form without selecting file
			{
				UInt16 separatorBytes = 0x0A0D;
				NSMutableData* separatorData = [NSMutableData dataWithBytes:&separatorBytes length:2];
				[separatorData appendData:[multipartData objectAtIndex:0]];
				int l = [separatorData length];
				int count = 1;	//number of times the separator shows up at the end of file data
				
				NSFileHandle* dataToTrim = [multipartData lastObject];
				//NSLog(@"data: %@", dataToTrim);
				uploading=YES;
				for (unsigned long long i = [dataToTrim offsetInFile] - l; i > 0; i--)
				{
					//NSLog(@"Loop %d",i);
					[dataToTrim seekToFileOffset:i];
					if ([[dataToTrim readDataOfLength:l] isEqualToData:separatorData])
					{
						//NSLog(@"Loop cond true at i=%d",i2);
						[dataToTrim truncateFileAtOffset:i];
						i -= l;
						if (--count == 0) break;
					}
					//NSLog(@"End Loop %d",i);
				}
				uploading=NO;
				//NSLog(@"NewFileUploaded");
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"NewFileUploaded" object:nil];
			}
			
			//for (int n = 1; n < [multipartData count] - 1; n++)
			//	NSLog(@"%@", [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:n] bytes] length:[[multipartData objectAtIndex:n] length] encoding:NSUTF8StringEncoding]);
			
			[postInfo release];
			[multipartData release];
			postContentLength = 0;
			NSLog(@"Upload done. sending response");
			if([path isEqualToString:@"/uploadMapsDB?api=1"]) {
				NSString *page=[self createAPI_dbUploadOK];
				NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
				HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
				return resp;
			} else {
				NSString *page=[self createUploadOKPage];
				NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
				HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
				return resp;
			}
		}
		else {
			NSString *page=[self createUploadMapDBPage];
			NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
			HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data]  autorelease];
			return resp;
		}
		
	} else if([path hasPrefix:@"/uploadDirectionsDB"]) {
		
		if (postContentLength > 0)		//process POST data
		{
			//NSLog(@"processing post data: %i", postContentLength);
			
			NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes] length:[[multipartData objectAtIndex:1] length] encoding:NSUTF8StringEncoding];
			NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
			postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
			postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
			NSString* filename = [postInfoComponents lastObject];
			
			if (![filename isEqualToString:@""]) //this makes sure we did not submitted upload form without selecting file
			{
				UInt16 separatorBytes = 0x0A0D;
				NSMutableData* separatorData = [NSMutableData dataWithBytes:&separatorBytes length:2];
				[separatorData appendData:[multipartData objectAtIndex:0]];
				int l = [separatorData length];
				int count = 1;	//number of times the separator shows up at the end of file data
				
				NSFileHandle* dataToTrim = [multipartData lastObject];
				//NSLog(@"data: %@", dataToTrim);
				uploading=YES;
				for (unsigned long long i = [dataToTrim offsetInFile] - l; i > 0; i--)
				{
					//NSLog(@"Loop %d",i);
					[dataToTrim seekToFileOffset:i];
					if ([[dataToTrim readDataOfLength:l] isEqualToData:separatorData])
					{
						//NSLog(@"Loop cond true at i=%d",i2);
						[dataToTrim truncateFileAtOffset:i];
						i -= l;
						if (--count == 0) break;
					}
					//NSLog(@"End Loop %d",i);
				}
				uploading=NO;
				//NSLog(@"NewFileUploaded");
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"NewFileUploaded" object:nil];
			}
			
			//for (int n = 1; n < [multipartData count] - 1; n++)
			//	NSLog(@"%@", [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:n] bytes] length:[[multipartData objectAtIndex:n] length] encoding:NSUTF8StringEncoding]);
			
			[postInfo release];
			[multipartData release];
			postContentLength = 0;
			NSLog(@"Upload done. sending response");
			if([path isEqualToString:@"/uploadDirectionsDB?api=1"]) {
				NSString *page=[self createAPI_dbUploadOK];
				NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
				HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
				return resp;
			} else {
				NSString *page=[self createUploadDirectionsOKPage];
				NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
				HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
				return resp;
			}
		}
		else {
			NSString *page=[self createUploadDirectionsDBPage];
			NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
			HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
			return resp;
		}
		
	} else if([path isEqualToString:@"/"]) {
		NSString *str=[self createBrowseableIndex:@"/"];
		NSData *data=[str dataUsingEncoding:NSUTF8StringEncoding];
		HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
		return resp;	
	} else if([path isEqualToString:@"/api/getDeviceInfo"]) {
		NSString *page=[self createAPI_info];
		NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
		HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
		return resp;
	} else if([path isEqualToString:@"/api/getGPXTrack"]) {
		NSString *page=[self createAPI_GPXLogFiles];
		NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
		HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
		return resp;
	} else if([path isEqualToString:@"/gpxlogger"]) {
		NSString *page=[self createGPXLogFiles];
		NSData *data=[page dataUsingEncoding:NSUTF8StringEncoding];
		HTTPDataResponse *resp=[[[HTTPDataResponse alloc] initWithData:data] autorelease];
		return resp;
	} else if([path isEqualToString:@"/api/getTileDB"]) {
		HTTPFileResponse *resp=[[[HTTPFileResponse alloc] initWithFilePath:[APPDELEGATE.tiledb getDBFilename]] autorelease];
		return resp;
	} else if([path isEqualToString:@"/api/getDirectionsDB"]) {
		HTTPFileResponse *resp=[[[HTTPFileResponse alloc] initWithFilePath:[APPDELEGATE.dirbookmarks getDBFilename]] autorelease];
		return resp;
	} else if([path hasPrefix:@"/api/getGPXLogFile/"]) {
		
		NSString *filename=[path stringByReplacingOccurrencesOfString:@"/api/getGPXLogFile/" withString:@""];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xgps_gpx/"];
		NSString *file = [path stringByAppendingPathComponent:filename];
		HTTPFileResponse *resp=nil;
		if([[NSFileManager defaultManager] fileExistsAtPath:file])
			resp=[[[HTTPFileResponse alloc] initWithFilePath:file] autorelease];
		else
			resp=nil;
		return resp;
	}
	
	
	return nil;
}

/**
 * This method is called to handle data read from a POST.
 * The given data is part of the POST body.
 **/
- (void)processPostDataChunk:(NSData *)postDataChunk
{
	// Override me to do something useful with a POST.
	// If the post is small, such as a simple form, you may want to simply append the data to the request.
	// If the post is big, such as a file upload, you may want to store the file to disk.
	// 
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	//NSLog(@"processPostDataChunk");
	
	if (!postHeaderOK)
	{
		UInt16 separatorBytes = 0x0A0D;
		NSData* separatorData = [NSData dataWithBytes:&separatorBytes length:2];
		
		int l = [separatorData length];
		for (int i = 0; i < [postDataChunk length] - l; i++)
		{
			NSRange searchRange = {i, l};
			if ([[postDataChunk subdataWithRange:searchRange] isEqualToData:separatorData])
			{
				NSRange newDataRange = {dataStartIndex, i - dataStartIndex};
				dataStartIndex = i + l;
				i += l - 1;
				NSData *newData = [postDataChunk subdataWithRange:newDataRange];
				if ([newData length])
				{
					[multipartData addObject:newData];
					
				}
				else
				{
					postHeaderOK = TRUE;
					
					NSString* postInfo = [[NSString alloc] initWithBytes:[[multipartData objectAtIndex:1] bytes] length:[[multipartData objectAtIndex:1] length] encoding:NSUTF8StringEncoding];
					//NSArray* postInfoComponents = [postInfo componentsSeparatedByString:@"; filename="];
					//postInfoComponents = [[postInfoComponents lastObject] componentsSeparatedByString:@"\""];
					//postInfoComponents = [[postInfoComponents objectAtIndex:1] componentsSeparatedByString:@"\\"];
					NSString* filename =fileSaving;
					
					NSLog(@"Saving to %@",filename);
					NSRange fileDataRange = {dataStartIndex, [postDataChunk length] - dataStartIndex};
					
					[[NSFileManager defaultManager] createFileAtPath:filename contents:[postDataChunk subdataWithRange:fileDataRange] attributes:nil];
					//chmod([filename UTF8String], S_IRWXO);
					NSFileHandle *file = [[NSFileHandle fileHandleForUpdatingAtPath:filename] retain];
					
					if (file)
					{
						[file seekToEndOfFile];
						[multipartData addObject:file];
						[ file release];
					}
					
					[postInfo release];
					[fileSaving release];
					fileSaving=nil;
					break;
				}
			}
		}
	}
	else
	{
		//NSLog(@"header ok, writing");
		[(NSFileHandle*)[multipartData lastObject] writeData:postDataChunk];
	}
}

@end
#endif
