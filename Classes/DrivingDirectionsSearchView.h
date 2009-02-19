//
//  SearchPlacesView.h
//  xGPS
//
//  Created by Mathieu on 9/20/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoEncoder.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MapView.h"
#import "RoutesManagerViewController.h"
@class MainViewController;
@interface DrivingDirectionsSearchView : UIView<ABPeoplePickerNavigationControllerDelegate,UISearchBarDelegate,UIActionSheetDelegate,RoutesManagerDelegate> {
	MainViewController* controller;
	MapView *map;
	float keyboardHeight;
	NSDictionary *_result;
	UIToolbar *bigbar;
	UISearchBar *from;
	UISearchBar *to;
	UISearchBar *bookmarkClicked;
	NSString *currentPosition;
	UIView *dummyView;
}
- (id)initWithFrame:(CGRect)frame andController:(MainViewController*)_controller andMap:(MapView*)map;
@end
