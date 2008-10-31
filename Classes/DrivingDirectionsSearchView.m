//
//  SearchPlacesView.m
//  xGPS
//
//  Created by Mathieu on 9/20/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "DrivingDirectionsSearchView.h"


@implementation DrivingDirectionsSearchView


- (id)initWithFrame:(CGRect)frame andController:(UIViewController*)_controller andMap:(MapView*)_map{
    if (self = [super initWithFrame:frame]) {
		controller=_controller;
        // Initialization code
		map=_map;
		self.backgroundColor=[UIColor clearColor];
		bigbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0,0,frame.size.width,80)];
		bigbar.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		from=[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,frame.size.width,40)];
		from.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		from.showsCancelButton=NO;
		from.showsBookmarkButton=YES;
		from.autocorrectionType=UITextAutocorrectionTypeNo;
		to=[[UISearchBar alloc] initWithFrame:CGRectMake(0,40,frame.size.width,40)];
		to.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		to.showsCancelButton=NO;
		to.showsBookmarkButton=YES;
		to.delegate=self;
		from.delegate=self;
		to.autocorrectionType=UITextAutocorrectionTypeNo;
		to.placeholder=NSLocalizedString(@"To / Destination",@"Driving to ");
		from.placeholder=NSLocalizedString(@"From / Departure",@"Driving from ");
		[from becomeFirstResponder];
		[bigbar addSubview:from];
		[bigbar addSubview:to];
		bookmarkClicked=nil;
	
		[self addSubview:bigbar];
	}
    return self;
}

- (void)dealloc {
    [super dealloc];
}
-(void)drive {

}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
	ABPeoplePickerNavigationController *picker =
	[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	bookmarkClicked=searchBar;
	picker.displayedProperties=[NSArray arrayWithObject:[NSNumber numberWithInt: kABPersonAddressProperty]];
    [controller presentModalViewController:picker animated:YES];
    [picker release];
}
- (void)didMoveToSuperview {
	from.text=@"";
	to.text=@"";

	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[from becomeFirstResponder];
}
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
	
	ABMultiValueRef multi=ABRecordCopyValue(person,property);
	NSDictionary *dic=(NSDictionary*)ABMultiValueCopyValueAtIndex(multi,identifier);
	NSString *out=@"";
	
	if([dic objectForKey:(NSString*)kABPersonAddressStreetKey]!=nil)
		out=[NSString stringWithFormat:@"%@, ",[dic objectForKey:(NSString*)kABPersonAddressStreetKey]];
	if([dic objectForKey:(NSString*)kABPersonAddressCityKey]!=nil)
		out=[NSString stringWithFormat:@"%@%@ ",out,[dic objectForKey:(NSString*)kABPersonAddressCityKey]];
	if([dic objectForKey:(NSString*)kABPersonAddressStateKey]!=nil)
		out=[NSString stringWithFormat:@"%@%@ ",out,[dic objectForKey:(NSString*)kABPersonAddressStateKey]];
	if([dic objectForKey:(NSString*)kABPersonAddressZIPKey]!=nil)
		out=[NSString stringWithFormat:@"%@%@ ",out,[dic objectForKey:(NSString*)kABPersonAddressZIPKey]];
	if([dic objectForKey:(NSString*)kABPersonAddressCountryKey]!=nil)
		out=[NSString stringWithFormat:@"%@%@",out,[dic objectForKey:(NSString*)kABPersonAddressCountryKey]];

	
	bookmarkClicked.text=out;
	
	if(bookmarkClicked==from)
		[to becomeFirstResponder];
	else
		[self drive];
	
	bookmarkClicked=nil;
	
	CFRelease(dic);
	CFRelease(multi);
	
	[controller dismissModalViewControllerAnimated:YES];


    return NO;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [controller dismissModalViewControllerAnimated:YES];
}
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}



@end
