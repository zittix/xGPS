//
//  SearchPlacesView.h
//  xGPS
//
//  Created by Mathieu on 9/20/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@interface SearchPlacesView : UIView<UISearchBarDelegate,ABPeoplePickerNavigationControllerDelegate> {
	UIView *dummyView;
	UISearchBar *searchBar;
	UIViewController* controller;
}
- (id)initWithFrame:(CGRect)frame andController:(UIViewController*)_controller;
@end
