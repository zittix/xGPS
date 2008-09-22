//
//  GPSSelectorViewController.h
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPSLicenseViewController.h"

@interface GPSSelectorViewController : UITableViewController {
	NSDictionary* gpsList;
	GPSLicenseViewController *licenseView;
	BOOL waitingForLicense;
}

@end
