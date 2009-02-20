//
//  ProgressViewController.h
//  xGPS
//
//  Created by Mathieu on 20.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProgressView.h"
@interface ProgressViewController : UIViewController {
	ProgressView *progress;
}
@property (nonatomic,readonly) ProgressView* progress;
@end
