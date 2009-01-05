//
//  TransferController.m
//  xGPS
//
//  Created by Mathieu on 25.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TransferController.h"
#import "xGPSAppDelegate.h"
#import "xGPSHTTPConnection.h"
@implementation TransferController
@synthesize delegate;
-(id)init {
	if((self=[super init])) {
#ifdef HAS_HTTPSERVER
		httpServer = [HTTPServer new];
		[httpServer setType:@"_xgps._tcp."];
		//NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
		
		[httpServer setConnectionClass:[xGPSHTTPConnection class]];
		//[httpServer setDocumentRoot:[NSURL fileURLWithPath:root]];
		[httpServer setPort:WIRELESS_TRANSFER_PORT];
		httpServer.delegate=self;
#endif
	}
	return self;
}
-(void)nbConnectionChanged:(int)nb {
	[delegate txstatusChanged:[NSString stringWithFormat:NSLocalizedString(@"%d connected clients",@""),nb]];
}

-(void)startServer {
	if(started) return;
#ifdef HAS_HTTPSERVER
	NSError *error;
	if(![httpServer start:&error])
	{
		NSLog(@"Error starting HTTP Server: %@", error);
		return;
	}
#endif
	started=YES;
	NSLog(@"Server started.");
}
-(void)dealloc {
#ifdef HAS_HTTPSERVER	
	[httpServer release];
#endif
	[super dealloc];
}
-(void)stopServer {
	if(!started) return;
	started=NO;
#ifdef HAS_HTTPSERVER
	[httpServer stop];
#endif
	NSLog(@"Server stopped");
}
@end
