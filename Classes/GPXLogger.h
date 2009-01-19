//
//  GPXLogger.h
//  xGPS
//
//  Created by Mathieu on 19.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GPXLogger : NSObject {
	BOOL logging;
	FILE *fp;
	BOOL hasSignal;
	NSString *currentFile;
}
-(void)startLogging;
-(void)stopLogging;
-(void)gpsSignalChanged:(BOOL)_hasSignal;
-(void)logGPXPoint:(float)lat lon:(float)lon alt:(float)alt speed:(float)speed fix:(int) fix sat:(int)sat;
-(NSString*)getLogFilename;
@end
