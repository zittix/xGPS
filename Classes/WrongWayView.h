//
//  WrongWayView.h
//  xGPS
//
//  Created by Mathieu on 26.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WrongWayView : UIView {
	UILabel *wrongWaylbl;
	BOOL run;
}
-(void)startAnimate;
-(void)stopAnimate;
@end
