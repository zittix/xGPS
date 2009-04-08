//
//  LicenseViewController.h
//  xGPS
//
//  Created by Mathieu on 9/18/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HideLicenseModalController
-(void)hideLicense;
@end


@interface LicenseViewController : UIViewController<UIWebViewDelegate> {
	id _delegate;
}
-(void)setDelegate:(id<HideLicenseModalController>)delegate;
@end
