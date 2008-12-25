//
//  TransferProtocol.m
//  xGPS
//
//  Created by Mathieu on 25.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TransferProtocol.h"


@implementation TransferProtocol
- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl
{
	if( self = [super init] ) {
		fileHandle = [fh retain];
		delegate = [dl retain];
		memset(&message,0,sizeof(xGPSProtocolMessage));
		isMessageComplete = NO;
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(dataReceivedNotification:)
				   name:NSFileHandleReadCompletionNotification
				 object:fileHandle];
		[fileHandle readInBackgroundAndNotify];
	}
	return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if( message.value ) free(message.value);
    [delegate release];
    [fileHandle release];
    [super dealloc];
}
-(void)treatMSG {
	NSLog(@"Got it !!!!");
}
- (void)dataReceivedNotification:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] objectForKey:
					NSFileHandleNotificationDataItem];
    
	if ( [data length] == 0 ) {
		// NSFileHandle's way of telling us
		// that the client closed the connection
		[delegate closeConnection:self];
	} else {
		[fileHandle readInBackgroundAndNotify];
		int headerSize=4+sizeof(unsigned long)+sizeof(unsigned int);

		if(!headerReceived) {
			int toCopy=[data length]>=headerSize ? headerSize : [data length];
			memcpy(&message, [data bytes], toCopy);
			receivedBytes+=toCopy;
			if(receivedBytes>=headerSize) {
				if(message.header[0]=='x' && message.header[1]=='G' && message.header[2]=='P' && message.header[3]=='S') {
					headerReceived=YES;
					NSLog(@"Allocating message of %d bytes",message.size);
					message.value=malloc(message.size);
					int rest=[data length] - toCopy;
					if(rest>0) {
						memcpy(message.value+receivedBytes,[data bytes],rest);
						receivedBytes+=rest;
					}
					
				} else {
					receivedBytes=0;
					headerReceived=NO;
				}
			}
		} else {
			int toCopy=[data length]>=message.size-receivedBytes-headerSize ? message.size-receivedBytes-headerSize : [data length];
			memcpy(message.value+receivedBytes,[data bytes],toCopy);
			receivedBytes+=toCopy;
		}
		
        if(headerReceived && receivedBytes-headerSize==message.size) {
			isMessageComplete=YES;
			[self treatMSG];
		}
			
	}
}
@end
