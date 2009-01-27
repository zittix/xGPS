//
//  GPSSignalView.h
//  xGPS
//
//  Created by Mathieu on 9/26/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowGPSDetailProtocol

-(void)showGPSDetails;

@end

@interface GPSSignalView : UIView {
	UIImage *red;
	UIImage *orange;
	UIImage *green;
	UIImage *grey;
	int quality;
	UILabel *gps;
	id delegate;
}
-(void)setQuality:(int)q;
- (id)initWithFrame:(CGRect)frame delegate:(id<ShowGPSDetailProtocol>)_delegate;
@end
