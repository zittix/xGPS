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
		searchBar.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		searchBar.showsCancelButton=YES;
		searchBar.showsBookmarkButton=YES;
		searchBar.autocorrectionType=UITextAutocorrectionTypeNo;
		
		self.autoresizesSubviews=YES;
		searchBar.delegate=self;
		searchBar.placeholder=NSLocalizedString(@"City name / Address",@"Placeholder for search bar of cities");

		[self addSubview:searchBar];
		
		//[searchBar becomeFirstResponder];
		map=_map;
		self.backgroundColor=[UIColor clearColor];
		geocoder=[[GeoEncoder alloc] init];
		geocoder.delegate=self;
		
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
	[searchBar release];
	[geocoder release];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if(_result!=nil) {
		[_result release];
		_result=nil;
		[tblView reloadData];
	}
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(_result==nil)
	return 0;
	else
		return [_result count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *key=[NSString stringWithFormat:@"%d",indexPath.row];
		
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:key] autorelease];
	}
	GeoEncoderResult *r=[_result objectForKey:key];
	cell.text=r.name;
	
	// Configure the cell
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *key=[NSString stringWithFormat:@"%d",indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	GeoEncoderResult* r=[_result objectForKey:key];
	
	[map updateCurrentPos:r.pos];
	[self searchBarCancelButtonClicked:searchBar];
}
- (void)keyboardWillShow:(NSNotification *)notif{
	CGRect keyboard;
	[[notif.userInfo objectForKey:UIKeyboardBoundsUserInfoKey]  getValue:&keyboard];
	keyboardHeight=keyboard.size.height;
	if(tblView==nil) {
			tblView=[[UITableView alloc] initWithFrame:CGRectMake(0,50,self.frame.size.width,self.frame.size.height-50-keyboardHeight) style:UITableViewStylePlain];
		tblView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		tblView.delegate=self;
		tblView.dataSource=self;
		[self addSubview:tblView];
	} else {
		tblView.frame=CGRectMake(0,50,self.frame.size.width,self.frame.size.height-50-keyboardHeight);
	}
	
	//NSLog(@"Show");
}
- (void)keyboardWillHide:(NSNotification *)notif{
	if(tblView==nil) {
		tblView=[[UITableView alloc] initWithFrame:CGRectMake(0,50,self.frame.size.width,self.frame.size.height-50) style:UITableViewStylePlain];
		tblView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		tblView.delegate=self;
		tblView.dataSource=self;
		[self addSubview:tblView];
	} else {
		tblView.frame=CGRectMake(0,50,self.frame.size.width,self.frame.size.height-50);
	}
	
	//NSLog(@"Show");
}
- (void)didMoveToSuperview {
	searchBar.text=@"";
	if(_result!=nil) {
		[_result release];
		_result=nil;
		[tblView reloadData];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[searchBar becomeFirstResponder];
}
-(void)geoEncodeGot:(NSDictionary*)result forRequest:(NSString*)req error:(NSError*)err {
	if(err==nil) {
	if([result count]>0) {
		NSEnumerator *enumerator = [result keyEnumerator];
		if([result count]==1) {
			//Automatic show result
			id key = [enumerator nextObject];
			GeoEncoderResult* r=[result objectForKey:key];
			
			[map updateCurrentPos:r.pos];
			[self searchBarCancelButtonClicked:searchBar];
		} else {
			_result=[result retain];
			[tblView reloadData];
		}
	} else {
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"No location has been found according to your query.",@"No location found error message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[alert show];
		
	}
	} else {
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:[NSString stringWithFormat:NSLocalizedString(@"Unable to retrieve the required information from the server: %@",@"Network error message"),[err localizedDescription]] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[alert show];

	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
	[searchBar becomeFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	if(_result!=nil) {
		[_result release];
		_result=nil;
		[tblView reloadData];
	}
	
	if(![geocoder geoencode:searchBar_.text]) {
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:[NSString stringWithFormat:NSLocalizedString(@"Unable to retrieve the required information from the server: %@",@"Network error message"),NSLocalizedString(@"Unknown error",@"Unknown error")] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[alert show];
		[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
		return;
	}
	[searchBar_ resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[UIView beginAnimations:nil context:nil];
	[self removeFromSuperview];
	
	[UIView commitAnimations];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; 
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
	//[searchBar becomeFirstResponder];
	[self searchBarSearchButtonClicked:searchBar];
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



@end
