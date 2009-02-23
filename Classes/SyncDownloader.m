//
//  SyncDownloader.m
//  xGPS
//
//  Created by Mathieu on 10/24/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "SyncDownloader.h"


@implementation SyncDownloader
-(id)init {
	if((self=[super init])) {
		finished=[[NSCondition alloc] init];
	}
	return self;
}
-(void)dealloc {
	[finished release];
	[receivedData release];
	[super dealloc];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
	//NSLog(@"Receive header ok");
    [receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	//NSLog(@"Receiving...");
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)err
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [err localizedDescription],
          [[err userInfo] objectForKey:NSErrorFailingURLStringKey]);
	error=YES;
	done=YES;
	[finished broadcast];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
   // NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	done=YES;
	[finished broadcast];
}
-(BOOL)download:(NSURLRequest*)req toData:(NSData**)data {
	error=NO;
	done=NO;
	//NSLog(@"Starting download...");
	if(receivedData!=nil) {
		[receivedData release];
		receivedData=nil;
	}
	receivedData=[[NSMutableData alloc] init];
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
	//NSLog(@"Current run loop: %@",[NSRunLoop currentRunLoop]);
	//NSLog(@"Main run loop: %@",[NSRunLoop mainRunLoop]);
	if (theConnection) {
		[theConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:[[NSRunLoop mainRunLoop] currentMode]];
		[finished lock];
		[theConnection start];
		
		//NSLog(@"Waiting for %@...",req.URL.absoluteString);
		while (!done) {
			[finished wait];
		}
		[finished unlock];
		//NSLog(@"End of wait");
	} else {
		error=YES;
	}
	//[theConnection unscheduleFromRunLoop:[NSRunLoop mainRunLoop] forMode:[[NSRunLoop mainRunLoop] currentMode]];
	[theConnection cancel];
	//[theConnection release];
	
	if(error) {
		if(receivedData!=nil) {
			//[receivedData release];
			receivedData=nil;
		}
	} else {
		*data=receivedData;
	}
	return !error;
}
@end
