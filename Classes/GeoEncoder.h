//
//  GeoEncoder.h
//  xGPS
//
//  Created by Mathieu on 9/22/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Position.h"
@protocol GeoEncoderDelegate
-(void)geoEncodeGot:(NSDictionary*)result forRequest:(NSString*)req error:(NSError*)err;

@end
@interface GeoEncoderResult : NSObject
{
	NSString *name;
	PositionObj* pos;
	NSString *addr;
}
@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* addr;
@property (nonatomic,retain) PositionObj* pos;
+(GeoEncoderResult*)resultWithName:(NSString*)name pos:(PositionObj*)pos addr:(NSString*)addr;
@end


@interface GeoEncoder : NSObject {
	NSString *req;
	id delegate;
	NSMutableDictionary* result;
	NSString *currentPlacename;
	NSString *currentPos;
	NSString *currentAddr;
	BOOL parsingPlace;
	NSMutableString *currentProp;
	NSMutableData *resultData;
	BOOL retryingWithoutLoc;
	BOOL location;
}
@property (nonatomic,assign) id delegate;
@property (nonatomic) BOOL location;
-(BOOL)geoencode:(NSString*)toEncode;
@end
