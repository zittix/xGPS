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
		httpServer = [HTTPServer new];
		[httpServer setType:@"_xgps._tcp."];
		//NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
		
		[httpServer setConnectionClass:[xGPSHTTPConnection class]];
		//[httpServer setDocumentRoot:[NSURL fileURLWithPath:root]];
		[httpServer setPort:WIRELESS_TRANSFER_PORT];
		httpServer.delegate=self;
	}
	return self;
}
-(void)nbConnectionChanged:(int)nb {
	[delegate txstatusChanged:[NSString stringWithFormat:NSLocalizedString(@"%d connected clients",@""),nb]];
}

-(void)startServer {
	if(started) return;
	NSError *error;
	if(![httpServer start:&error])
	{
		NSLog(@"Error starting HTTP Server: %@", error);
		return;
	}
	started=YES;
	NSLog(@"Server started.");
}
-(void)dealloc {
	[httpServer release];
	[super dealloc];
}
-(void)stopServer {
	if(!started) return;
	started=NO;
	[httpServer stop];
	NSLog(@"Server stopped");
}
@end
