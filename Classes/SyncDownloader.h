//
//  SyncDownloader.h
//  xGPS
//
//  Created by Mathieu on 10/24/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SyncDownloader : NSObject {
	NSCondition *finished;
	BOOL error;
	NSMutableData* receivedData;
	BOOL done;
}
-(BOOL)download:(NSURLRequest*)req toData:(NSData**)data;
@end
