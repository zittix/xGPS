//
//  TransferController.m
//  xGPS
//
//  Created by Mathieu on 25.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TransferController.h"
#import "xGPSAppDelegate.h"

@implementation TransferController
@synthesize delegate;
-(void)setStatus:(NSString*)s {
	[delegate txstatusChanged:s];
}

-(void)startServer {
	if(started) return;
	//portNumber=WIRELESS_TRANSFER_PORT;
	started=YES;
	NSLog(@"Server started.");
}
-(void)dealloc {
	[self stopServer];
	[super dealloc];
}
-(void)stopServer {
	if(!started) return;
	started=NO;
	NSLog(@"Server stopped");
}
@end
