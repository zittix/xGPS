//
//  NavigationPoint.h
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"

@interface NavigationPoint : NSObject {
	PositionObj *pos;
	NSString *name;
}
@property (nonatomic,retain) NSString *name;
@property (nonatomic,assign) PositionObj *pos;
@end
