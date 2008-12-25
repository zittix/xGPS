//
//  TransferProtocol.h
//  xGPS
//
//  Created by Mathieu on 25.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TransferProtocol;
@protocol TransferProtocolDelegate
-(void)closeConnection:(TransferProtocol*)t;
-(void)setStatus:(NSString*)s;
@end

typedef struct xGPSProtocolMessage {
	char header[4];
	unsigned long size;
	unsigned int action;
	char *value;
} xGPSProtocolMessage;

@interface TransferProtocol : NSObject {
	NSFileHandle *fileHandle;
    id delegate;
	xGPSProtocolMessage message;
	BOOL isMessageComplete;
	BOOL headerReceived;
	int receivedBytes;
}
- (id)initWithFileHandle:(NSFileHandle *)fh delegate:(id)dl;
@end
