//
//  GeoEncoder.h
//  xGPS
//
//  Created by Mathieu on 9/22/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Position.h"
@protocol DirectionsControllerDelegate
-(void)geoEncodeGot:(NSDictionary*)result forRequest:(NSString*)req error:(NSError*)err;

@end
@interface Instruction : NSObject
{
	NSString *name;
	NSString *descr;
	PositionObj* pos;
}
@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* descr;
@property (nonatomic,retain) PositionObj* pos;
+(Instruction*)instrWithName:(NSString*)name pos:(PositionObj*)pos descr:(NSString*)descr;
@end


@interface DirectionsController : NSObject {
	NSString *_from;
	NSString *_to;
	id delegate;
	NSMutableDictionary* instructions;
	NSMutableArray* roadPoints;
	NSString *currentPlacename;
	NSString *currentPos;
	NSString *currentDescr;
	BOOL parsingPlace;
	NSMutableString *currentProp;
	NSMutableData *resultData;
	BOOL computing;
	BOOL parsingLinestring;
}
@property (nonatomic,assign) id delegate;
-(BOOL)drive:(NSString*)from to:(NSString*)to;
@end
