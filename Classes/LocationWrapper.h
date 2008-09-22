//
//  LocationWrapper.h
//  xGPS
//
//  Created by Mathieu on 6/16/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "Position.h"
@protocol LocationWrapperProtocol
- (void)updateCurrentPos:(PositionObj*) p;
- (void)setHasGPSPos:(BOOL)val;
@end
