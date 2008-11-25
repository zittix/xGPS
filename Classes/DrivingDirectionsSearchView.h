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
@interface DrivingDirectionsSearchView : UIView<ABPeoplePickerNavigationControllerDelegate,UISearchBarDelegate,UIActionSheetDelegate> {
	UIViewController* controller;
	MapView *map;
	float keyboardHeight;
	NSDictionary *_result;
	UIToolbar *bigbar;
	UISearchBar *from;
	UISearchBar *to;
	UISearchBar *bookmarkClicked;
		NSString *currentPosition;
}
- (id)initWithFrame:(CGRect)frame andController:(UIViewController*)_controller andMap:(MapView*)map;
-(void)setEdit;
@end
