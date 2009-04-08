//
//  DirectionsRetriever.h
//  xGPS
//
//  Created by Mathieu on 08.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"

typedef enum RoutingType {
	ROUTING_NORMAL, ROUTING_AVOID_HIGHWAY, ROUTING_BY_FOOT
} RoutingType;

@protocol DirectionsRetrieverProtocol

-(void)directionsGot:(NSMutableArray*)instructions roads:(NSMutableArray*)roadPoints from:(NSString*)from to:(NSString*)to via:(NSArray*)via error:(NSString*)error;

@end


@interface DirectionsRetriever : NSObject {
	BOOL retrieving;
	id delegate;
	
	NSString *_from;
	NSString *_to;
	NSArray *_via;
	NSMutableArray* instructions;
	NSMutableArray* roadPoints;
	NSString *currentPlacename;
	NSString *currentPos;
	NSString *currentDescr;
	NSString *startAddr;
	NSString *stopAddr;
	BOOL parsingPlace;
	NSMutableString *currentProp;
	NSMutableData *resultData;
	BOOL parsingLinestring;
	PositionObj* pos;		
}
-(BOOL)getDirections:(NSString*)from to:(NSString*)to via:(NSArray*)via delegate:(id<DirectionsRetrieverProtocol>)_tmpDelegate routing:(RoutingType)routingType;
@end
