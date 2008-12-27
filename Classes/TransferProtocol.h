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
#define MSG_ACTION_HELLO 1
#define MSG_ACTION_GET_MAPDB_SIZE 2
#define MSG_ACTION_RETURN_MAPDB_SIZE 3
#define PROTOCOL_VERSION "1.0"
typedef struct xGPSProtocolMessage {
	char header[4];
	char byteOrder;
	unsigned int size;
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
-(void)sendWelcome;
+(char*)getDataFromStruct:(xGPSProtocolMessage*)msg length:(int*)l;
@end
