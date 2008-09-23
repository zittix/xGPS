//
//  SearchPlacesView.m
//  xGPS
//
//  Created by Mathieu on 9/20/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "SearchPlacesView.h"


@implementation SearchPlacesView


- (id)initWithFrame:(CGRect)frame andController:(UIViewController*)_controller andMap:(MapView*)_map{
    if (self = [super initWithFrame:frame]) {
		controller=_controller;
        // Initialization code
		
		searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,frame.size.width,50)];
		dummyView=[[UIView alloc] initWithFrame:CGRectMake(0,50,frame.size.width,frame.size.height-50)];
				   dummyView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		searchBar.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		searchBar.showsCancelButton=YES;
		searchBar.showsBookmarkButton=YES;
		self.autoresizesSubviews=YES;
		searchBar.delegate=self;
		[self addSubview:searchBar];
		[self addSubview:dummyView];
		[searchBar becomeFirstResponder];
		map=_map;
		self.backgroundColor=[UIColor clearColor];
		geocoder=[[GeoEncoder alloc] init];
		geocoder.delegate=self;
    }
    return self;
}
- (void)didMoveToSuperview {
	searchBar.text=@"Ch. du Marais 9, Mex 1031, Switzerland";
	[searchBar becomeFirstResponder];
}
-(void)geoEncodeGot:(NSDictionary*)result forRequest:(NSString*)req {
	//CFShow(result);
	if([result count]>0) {
		NSEnumerator *enumerator = [result keyEnumerator];
		if([result count]==1) {
				//Automatic show result
			id key = [enumerator nextObject];
	
			
			[map updateCurrentPos:[result objectForKey:key]];
			[self searchBarCancelButtonClicked:searchBar];
		} else {
			id key=nil;
			while ((key = [enumerator nextObject])) {
				/* code that uses the returned key */
			}
		}
	}
	//[result release];
	//[req release];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
	NSLog(@"Search");
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	[geocoder geoencode:searchBar_.text];
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[UIView beginAnimations:nil context:nil];
	[self removeFromSuperview];
	[UIView commitAnimations];
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
	ABPeoplePickerNavigationController *picker =
	[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	picker.displayedProperties=[NSArray arrayWithObject:[NSNumber numberWithInt: kABPersonAddressProperty]];
    [controller presentModalViewController:picker animated:YES];
    [picker release];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
	
	ABMultiValueRef multi=ABRecordCopyValue(person,property);
	NSDictionary *dic=(NSDictionary*)ABMultiValueCopyValueAtIndex(multi,identifier);
	NSString *out=[NSString stringWithFormat:@"%@, %@ %@ %@, %@",[dic objectForKey:(NSString*)kABPersonAddressStreetKey],[dic objectForKey:(NSString*)kABPersonAddressCityKey],[dic objectForKey:(NSString*)kABPersonAddressStateKey],[dic objectForKey:(NSString*)kABPersonAddressZIPKey],[dic objectForKey:(NSString*)kABPersonAddressCountryKey]];
	searchBar.text=out;
	
	CFRelease(dic);
	CFRelease(multi);
	
	[controller dismissModalViewControllerAnimated:YES];
	[searchBar becomeFirstResponder];
    return NO;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [controller dismissModalViewControllerAnimated:YES];
	[searchBar becomeFirstResponder];
}
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
	NSSet *events=[event touchesForView:dummyView];

	if([events count]>0) {
		[UIView beginAnimations:nil context:nil];
		[self removeFromSuperview];
		[UIView commitAnimations];
	}
		
}

- (void)dealloc {
    [super dealloc];
}


@end