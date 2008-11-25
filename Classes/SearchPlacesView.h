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
@class MainViewController;
@interface SearchPlacesView : UIView<UISearchBarDelegate,ABPeoplePickerNavigationControllerDelegate,GeoEncoderDelegate,UITableViewDelegate,UITableViewDataSource> {
	UISearchBar *searchBar;
	UIViewController* controller;
	GeoEncoder *geocoder;
	MapView *map;
	UITableView *tblView;
	float keyboardHeight;
	NSDictionary *_result;
	id viewController;
}
- (id)initWithFrame:(CGRect)frame andController:(MainViewController*)_controller andMap:(MapView*)map;
@end
