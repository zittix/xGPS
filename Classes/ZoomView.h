//
//  ZoomView.h
//  xGPS
//
//  Created by Mathieu on 6/14/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZoomingProtocol
-(void)zoomin:(id)sender;
-(void)zoomout:(id)sender;
@end
@interface ZoomView : UIView {
	UIButton *zoomin;
	UIButton *zoomout;
	id delegate;
}
-(id) initWithFrame:(CGRect)f withDelegate:(id)_delegate;
-(void)setZoomoutState:(BOOL)s;
-(void)setZoominState:(BOOL)s;
@end
