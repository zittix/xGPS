//
//  ViewSearch.h
//  xGPS
//
//  Created by Mathieu on 23.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewSearchProtocol

-(void)btnSearchPlacePressed;
-(void)btnSearchRoutePressed;
-(void)btnRoutesManagerPressed;
-(void)btnHomePressed;
-(void)btnClearPressed;
@end


@interface ViewSearch : UIView {
	UIImageView *bg;
	UIButton *searchPlace;
	UIButton *searchRoute;
	UIButton *routesManager;
	UIButton *home;
	UIButton *clear;
	UIButton *close;
}

-(id)initWithFrame:(CGRect)frame delegate:(id<ViewSearchProtocol>)_delegate;
-(void)changeOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(void)showInView:(UIView*)view;
-(void)hide;
@end
