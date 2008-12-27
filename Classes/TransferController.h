//
//  TransferController.h
//  xGPS
//
//  Created by Mathieu on 25.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TransferControllerDelegate

-(void)txstatusChanged:(NSString*)status;

@end


@interface TransferController : NSObject {
	BOOL started;
	id delegate;
}

-(void)startServer;
-(void)stopServer;
@property (nonatomic,assign) id delegate;
@end
