//
//  TransferProtocol.m
//  xGPS
//
//  Created by Mathieu on 25.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TransferProtocol.h"
#import "xGPSAppDelegate.h"

@implementation TransferProtocol
- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl
{
	if( self = [super init] ) {
		fileHandle = [fh retain];
		delegate = [dl retain];
		memset(&message,0,sizeof(xGPSProtocolMessage));
		isMessageComplete = NO;
		[self sendWelcome];
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
	NSLog(@"Protocol freed");
    [super dealloc];
}
-(void)treatMSG {
	NSLog(@"Got it !!!!");
}
-(void)sendWelcome {
	//Build welcome message packet
	xGPSProtocolMessage msg;
	msg.header[0]='x';
	msg.header[1]='G';
	msg.header[2]='P';
	msg.header[3]='S';
	msg.action=MSG_ACTION_HELLO;
	NSString *val=@VERSION":"PROTOCOL_VERSION;
	
	//Test byte order
	unsigned int b=1;
	unsigned char b2 = b >> (sizeof(unsigned int)-1)*8;
	msg.byteOrder=b2==1 ? 'b' : 'l';
	NSLog(@"Edian mode: %c",msg.byteOrder);
	msg.value=(char*)[val UTF8String];
	msg.size=[val length]+1;
	int length=0;
	char *buf=[TransferProtocol getDataFromStruct:&msg length:&length];
	
	@try {
		[fileHandle writeData:[NSData dataWithBytes:buf length:length]];
	}
	@catch (NSException *exception) {
		NSLog(@"Error while transmitting data for welcome message");
	}
	free(buf);
	[val release];
}
+(char*)getDataFromStruct:(xGPSProtocolMessage*)msg length:(int*)l {
	int msgLen=5+sizeof(unsigned int)+sizeof(unsigned int)+msg->size;
	char *buf=malloc(msgLen);
	memcpy(buf, msg->header, 4);
	memcpy(buf+4, &msg->byteOrder, 1);
	memcpy(buf+5, &msg->size, sizeof(unsigned int));
	memcpy(buf+5+ sizeof(unsigned int), &msg->action, sizeof(unsigned int));
	memcpy(buf+5+2* sizeof(unsigned int), msg->value, msg->size);
	*l=msgLen;
	return buf;
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
		int headerSize=5+sizeof(unsigned int)+sizeof(unsigned int);

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
