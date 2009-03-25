//
//  HomeAddressViewController.h
//  xGPS
//
//  Created by Mathieu on 23.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface HomeAddressViewController : UITableViewController<UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate> {
	UITextField *txtHome;
}

@end
