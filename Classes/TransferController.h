//
//  TransferController.h
//  xGPS
//
//  Created by Mathieu on 25.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransferProtocol.h"
@protocol TransferControllerDelegate

-(void)txstatusChanged:(NSString*)status;

@end


@interface TransferController : NSObject<TransferProtocolDelegate> {
	BOOL started;
	int portNumber;
	id delegate;
	int fdPort;
	NSFileHandle *fileHandle;
	CFSocketRef socket;
	NSMutableArray *connections; 
	NSNetService* service;
}
-(void)startServer;
-(void)stopServer;
@property (nonatomic,assign) id delegate;
@end
