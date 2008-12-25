//
//  TransferController.m
//  xGPS
//
//  Created by Mathieu on 25.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TransferController.h"
#import "xGPSAppDelegate.h"
#import <sys/socket.h>   // for AF_INET, PF_INET, SOCK_STREAM, SOL_SOCKET, SO_REUSEADDR
#import <netinet/in.h>   // for IPPROTO_TCP, sockaddr_in
@implementation TransferController
@synthesize delegate;
-(void)serverThread {
	
}
-(void)setStatus:(NSString*)s {
	[delegate txstatusChanged:s];
}
- (void)closeConnection:(TransferProtocol *)t;
{
    unsigned connectionIndex = [connections indexOfObjectIdenticalTo:t];
    if( connectionIndex == NSNotFound ) return;
	    
    NSIndexSet *connectionIndexSet = [NSIndexSet indexSetWithIndex:connectionIndex];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:connectionIndexSet
              forKey:@"connections"];
        [connections removeObjectsAtIndexes:connectionIndexSet];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:connectionIndexSet
             forKey:@"connections"];
}

-(void)startServer {
	if(started) return;
	portNumber=WIRELESS_TRANSFER_PORT;
	
	connections = [[NSMutableArray alloc] init];
	
	
	int fd = -1;
	socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM,
							IPPROTO_TCP, 0, NULL, NULL);
	if( socket ) {
		fd = CFSocketGetNative(socket);
		int yes = 1;
		setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
		
		struct sockaddr_in addr;
		memset(&addr, 0, sizeof(addr));
		addr.sin_len = sizeof(addr);
		addr.sin_family = AF_INET;
		addr.sin_port = htons(portNumber);
		addr.sin_addr.s_addr = htonl(INADDR_ANY);
		NSData *address = [NSData dataWithBytes:&addr length:sizeof(addr)];
		if( CFSocketSetAddress(socket, (CFDataRef)address) !=
		   kCFSocketSuccess ) {
			NSLog(@"Could not bind to address");
		}
		
	} else {
		NSLog(@"No server socket");
	}
	fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd
											   closeOnDealloc:YES];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(newConnection:)
			   name:NSFileHandleConnectionAcceptedNotification
			 object:nil];
	
	[fileHandle acceptConnectionInBackgroundAndNotify];
	
	service = [[NSNetService alloc] initWithDomain:@"local."// 4
											  type:@"_xgps._tcp."
name:[NSString stringWithFormat:NSLocalizedString(@"xGPS on %@",@""),[[NSProcessInfo processInfo].hostName stringByReplacingOccurrencesOfString:@".local" withString:@""]] port:portNumber];
    if(service)
    {
        [service setDelegate:self];// 5
        [service publish];// 6
    }
    else
    {
        NSLog(@"An error occurred initializing the NSNetService object.");
    }
	started=YES;
	NSLog(@"Server started.");
}

// Sent when the service is about to publish
- (void)netServiceWillPublish:(NSNetService *)netService
{
   // [services addObject:netService];
    // You may want to do something here, such as updating a user interface
	NSLog(@"Service published");
}

// Error handling code
- (void)handleError:(NSNumber *)error withService:(NSNetService *)_service
{
    NSLog(@"An error occurred with service %@.%@.%@, error code = %@",
		  [_service name], [_service type], [_service domain], error);
    // Handle error here
}

// Sent if publication fails
- (void)netService:(NSNetService *)netService
	 didNotPublish:(NSDictionary *)errorDict
{
    //[self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
    //[services removeObject:netService];
}

// Sent when the service stops
- (void)netServiceDidStop:(NSNetService *)netService
{
    //[services removeObject:netService];
    // You may want to do something here, such as updating a user interface
}

- (void)newConnection:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSFileHandle *remoteFileHandle = [userInfo objectForKey:
									  NSFileHandleNotificationFileHandleItem];
	
	NSNumber *errorNo = [userInfo objectForKey:@"NSFileHandleError"];
	if( errorNo ) {
		NSLog(@"NSFileHandle Error: %@", errorNo);
		return;
	}
	
	[fileHandle acceptConnectionInBackgroundAndNotify];
	
	if( remoteFileHandle ) {
		TransferProtocol *connection;
		connection = [[TransferProtocol alloc] initWithFileHandle:
					  remoteFileHandle
															 delegate:self];
		if( connection ) {
			NSIndexSet *insertedIndexes;
			insertedIndexes = [NSIndexSet indexSetWithIndex:
							   [connections count]];
			[self willChange:NSKeyValueChangeInsertion
             valuesAtIndexes:insertedIndexes forKey:@"connections"];
			[connections addObject:connection];
			[self didChange:NSKeyValueChangeInsertion
			valuesAtIndexes:insertedIndexes forKey:@"connections"];
			[connection release];
		}
	}
}
-(void)stopServer {
	if(!started) return;
	
	[service stop];
	[service release];
	service=nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [connections release];
    [fileHandle release];
	CFSocketInvalidate(socket);
	CFRelease(socket);

	connections=nil;
	fileHandle=nil;
    [super dealloc];
	NSLog(@"Server stopped");
}
@end
