//
//  GeoEncoder.h
//  xGPS
//
//  Created by Mathieu on 9/22/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Position.h"
#import "NavigationInstructionView.h"
@class MapView;
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
@protocol DirectionsControllerDelegate
-(void)directionsGot:(NSString*)from to:(NSString*)to error:(NSError*)err;
-(void)nextDirectionChanged:(Instruction*)instr;
@end

@interface DirectionsController: NSObject<DrivingInstructionMovingProtocol> {
	NSString *_from;
	NSString *_to;
	id delegate;
	NSMutableArray* instructions;
	NSMutableArray* roadPoints;
	NSString *currentPlacename;
	NSString *currentPos;
	NSString *currentDescr;
	BOOL parsingPlace;
	NSMutableString *currentProp;
	NSMutableData *resultData;
	BOOL computing;
	BOOL parsingLinestring;
	PositionObj* pos;
	int instrIndex;
	MapView *map;
	int previousSegement;
	int previousInstruction;
}
@property (nonatomic,retain) id delegate;
@property (nonatomic,readonly) NSMutableArray* roadPoints;
@property (nonatomic,readonly) NSMutableArray* instructions;
@property (nonatomic,assign) MapView* map;
@property (nonatomic,setter=updatePos:,assign) PositionObj* pos;
-(BOOL)drive:(NSString*)from to:(NSString*)to;
@end
