//
//  SettingsGeneralController.h
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutViewController.h"
#import "LanguageViewController.h"
@interface SettingsGeneralController : UITableViewController {
	AboutViewController *aboutView;
	LanguageViewController *langView;
}

@end
