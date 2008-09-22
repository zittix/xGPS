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
@interface SearchPlacesView : UIView<UISearchBarDelegate,ABPeoplePickerNavigationControllerDelegate,GeoEncoderDelegate> {
	UIView *dummyView;
	UISearchBar *searchBar;
	UIViewController* controller;
	GeoEncoder *geocoder;
	MapView *map;
}
- (id)initWithFrame:(CGRect)frame andController:(UIViewController*)_controller andMap:(MapView*)map;
@end
