//
//  SearchPlacesView.m
//  xGPS
//
//  Created by Mathieu on 9/20/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "SearchPlacesView.h"
#import "MainViewController.h"

@implementation SearchPlacesView


- (id)initWithFrame:(CGRect)frame andController:(UIViewController*)_controller delegate:(id<SearchPlacesViewDelegate>)_delegate {
    if ((self = [super initWithFrame:frame])) {
		viewController;
        // Initialization code
		delegate=_delegate;
		searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,frame.size.width,50)];
		searchBar.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		searchBar.showsCancelButton=YES;
		searchBar.showsBookmarkButton=YES;
		searchBar.autocorrectionType=UITextAutocorrectionTypeNo;
		self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.autoresizesSubviews=YES;
		searchBar.delegate=self;
		searchBar.placeholder=NSLocalizedString(@"City name / Address",@"Placeholder for search bar of cities");

		[self addSubview:searchBar];
	
		self.backgroundColor=[UIColor clearColor];
		geocoder=[[GeoEncoder alloc] init];
		geocoder.delegate=self;
		tblView=[[UITableView alloc] initWithFrame:CGRectMake(0,50,self.frame.size.width,self.frame.size.height-50) style:UITableViewStylePlain];
		tblView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		tblView.delegate=self;
		tblView.dataSource=self;
		tblView.rowHeight=60.0f;
		[self addSubview:tblView];
		viewController=_controller;
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
		UILabel *label;
		UILabel *value;
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, self.frame.size.width-50.0, 20.0f)] autorelease];
		label.tag = 2;
		label.font = [UIFont boldSystemFontOfSize:16.0];
		label.textAlignment = UITextAlignmentLeft;
		label.backgroundColor=[UIColor clearColor];
		label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
		value = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 20.0, self.frame.size.width-50.0, 35.0f)] autorelease];
		value.tag = 1;
		
		value.font = [UIFont systemFontOfSize:12.0];
		value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
		value.backgroundColor=[UIColor clearColor];
		value.lineBreakMode=UILineBreakModeWordWrap;
		value.textColor=[UIColor darkGrayColor];
		value.textAlignment=UITextAlignmentLeft;
		value.numberOfLines=2;
		[cell.contentView addSubview:value];
		[cell.contentView addSubview:label];
		
	}
	GeoEncoderResult *r=[_result objectForKey:key];
	
	if(r.addr!=nil)
	((UILabel*)[cell viewWithTag:1]).text=r.addr;
	else
	((UILabel*)[cell viewWithTag:1]).text=@"";	
	((UILabel*)[cell viewWithTag:2]).text=r.name;
	
	// Configure the cell
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *key=[NSString stringWithFormat:@"%d",indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	GeoEncoderResult* r=[_result objectForKey:key];
	/*
	map.pos=r.pos;
	[map setPosSearch:r.pos];
	((MainViewController*)viewController).currentSearchType=1;*/
	[delegate gotResultForSearch:r];
	[self searchBarCancelButtonClicked:searchBar];
}
- (void)keyboardWillShow:(NSNotification *)notif{
	CGRect keyboard;
	[[notif.userInfo objectForKey:UIKeyboardBoundsUserInfoKey]  getValue:&keyboard];
	keyboardHeight=keyboard.size.height;
	tblView.frame=CGRectMake(0,50,self.frame.size.width,self.frame.size.height-50-keyboardHeight);
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
}
- (void)willMoveToSuperview:(UIView*)view  {
	searchBar.text=@"";
	if(_result!=nil) {
		[_result release];
		_result=nil;
		[tblView reloadData];
	}
}
- (void)didMoveToSuperview {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[searchBar becomeFirstResponder];
}
-(void)geoEncodeGot:(NSDictionary*)result forRequest:(NSString*)req error:(NSError*)err {
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
	if(err==nil) {
	if([result count]>0) {
		NSEnumerator *enumerator = [result keyEnumerator];
		if([result count]==1) {
			//Automatic show result
			id key = [enumerator nextObject];
			GeoEncoderResult* r=[result objectForKey:key];
			
			[delegate gotResultForSearch:r];
			[self searchBarCancelButtonClicked:searchBar];
			return;
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
	
	[searchBar becomeFirstResponder];
}
-(void)setLocation:(BOOL)val {
	geocoder.location=val;
}
-(BOOL)location {
	return geocoder.location;
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
	[delegate searchPlaceWillHide];
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
    [viewController presentModalViewController:picker animated:YES];
    [picker release];
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

	
	searchBar.text=out;
	
	CFRelease(dic);
	CFRelease(multi);
	
	[viewController dismissModalViewControllerAnimated:YES];
	//[searchBar becomeFirstResponder];
	[self searchBarSearchButtonClicked:searchBar];
    return NO;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [viewController dismissModalViewControllerAnimated:YES];
	[searchBar becomeFirstResponder];
}
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}



@end
