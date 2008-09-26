//
//  GPSSignalView.h
//  xGPS
//
//  Created by Mathieu on 9/26/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GPSSignalView : UIView {
	UIImage *red;
	UIImage *orange;
	UIImage *green;
	int quality;
	UILabel *gps;
}
-(void)setQuality:(int)q;
@end
