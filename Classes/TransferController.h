//
//  TransferController.h
//  xGPS
//
//  Created by Mathieu on 25.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef HAS_HTTPSERVER
#import "HTTPServer.h"
#endif
@protocol TransferControllerDelegate

-(void)txstatusChanged:(NSString*)status;

@end

#ifdef HAS_HTTPSERVER
@interface TransferController : NSObject<HTTPServerProtocol> {
#else
@interface TransferController : NSObject {	
#endif
	BOOL started;
	id delegate;
#ifdef HAS_HTTPSERVER
	HTTPServer  *httpServer;
#endif
}

-(void)startServer;
-(void)stopServer;
@property (nonatomic,assign) id delegate;
#ifdef HAS_HTTPSERVER
@property (nonatomic,readonly) HTTPServer *httpServer;
#endif
@end
