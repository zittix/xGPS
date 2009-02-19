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

@protocol SearchPlacesViewDelegate

-(void)gotResultForSearch:(GeoEncoderResult*)result;
-(void)searchPlaceWillHide;
@end


@interface SearchPlacesView : UIView<UISearchBarDelegate,ABPeoplePickerNavigationControllerDelegate,GeoEncoderDelegate,UITableViewDelegate,UITableViewDataSource> {
	UISearchBar *searchBar;
	UIViewController* viewController;
	GeoEncoder *geocoder;
	UITableView *tblView;
	float keyboardHeight;
	NSDictionary *_result;
	id delegate;
}
- (id)initWithFrame:(CGRect)frame andController:(UIViewController*)_controller delegate:(id<SearchPlacesViewDelegate>)_delegate;
@end
