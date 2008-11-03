//
//  GeoEncoder.h
//  xGPS
//
//  Created by Mathieu on 9/22/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Position.h"
@protocol ADirectionsControllerDelegate
-(void)geoEncodeGot:(NSDictionary*)result forRequest:(NSString*)req error:(NSError*)err;

@end
@interface AGeoEncoderResult : NSObject
{
	NSString *name;
	PositionObj* pos;
	NSString *addr;
}
@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* addr;
@property (nonatomic,retain) PositionObj* pos;
+(AGeoEncoderResult*)resultWithName:(NSString*)name pos:(PositionObj*)pos addr:(NSString*)addr;
@end


@interface DirectionsController : NSObject {
	NSString *from;
	NSString *to;
	id delegate;
	NSMutableDictionary* result;
	NSString *currentPlacename;
	NSString *currentPos;
	NSString *currentAddr;
	BOOL parsingPlace;
	NSMutableString *currentProp;
	NSString * req;
	NSMutableData *resultData;
}
@property (nonatomic,assign) id delegate;
-(BOOL)geoencode:(NSString*)toEncode;
@end
