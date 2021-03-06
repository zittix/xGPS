//
//  SearchPlacesView.m
//  xGPS
//
//  Created by Mathieu on 9/20/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "DrivingDirectionsSearchView.h"
#import "xGPSAppDelegate.h"
#import "MainViewController.h"
#import "ProgressViewController.h"
@implementation DrivingDirectionsSearchView


- (id)initWithFrame:(CGRect)frame andController:(MainViewController*)_controller andMap:(MapView*)_map{
    if ((self = [super initWithFrame:frame])) {
		controller=_controller;
        // Initialization code
		map=_map;
		dummyView=[[UIView alloc] initWithFrame:CGRectMake(0,80,frame.size.width,frame.size.height-80)];
		[self addSubview:dummyView];
		self.backgroundColor=[UIColor clearColor];
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
		[self addSubview:from];
		[self addSubview:to];
		bookmarkClicked=nil;
		
		self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.autoresizesSubviews=YES;
	}
    return self;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSSet *events=[event touchesForView:dummyView];

	if([events count]>0) {
		[controller cancelDrivingSearch:self];
	}
}
-(void)setEditingKeyBoard {
	[from becomeFirstResponder];	
}
- (void)dealloc {
	[currentPosition release];
	[from release];
	[dummyView release];
	[to release];
    [super dealloc];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	
	NSString *fromT;
	if([from.text  isEqualToString:NSLocalizedString(@"Current Position",@"")]) {
		GPSController *g=[[xGPSAppDelegate gpsmanager] GetCurrentGPS];
		if(g.gps_data.fix.mode>1) {
			float lat=g.gps_data.fix.latitude;
			float lon=g.gps_data.fix.longitude;
			
			[currentPosition release];
			currentPosition=[[NSString alloc] initWithFormat:@"%f,%f",lat,lon];
		} 
		fromT=currentPosition;
	}else
		fromT=from.text;
	
	if(![APPDELEGATE.directions drive:fromT to:to.text via:nil delegate:nil]) {
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:[NSString stringWithFormat:NSLocalizedString(@"Unable to retrieve the required information from the server: %@",@"Network error message"),NSLocalizedString(@"Unknown error",@"Unknown error")] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[alert show];
		[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
		return;
	}
	controller.navigationItem.leftBarButtonItem.enabled=NO;
	controller.navigationItem.rightBarButtonItem.enabled=NO;
	[searchBar_ resignFirstResponder];
	
	ProgressViewController *pController=[[ProgressViewController alloc] init];
	
	[pController.progress hideCancelButton];
	pController.progress.ltext.text=NSLocalizedString(@"Computing your route...",@"");
	[pController.progress setProgress:0.2];
	APPDELEGATE.directions.routingType=ROUTING_NORMAL;
		
	[controller presentModalViewController:pController animated:NO];
	
	
}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
	
	bookmarkClicked=searchBar;
	UIActionSheet *action=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Take position from:",@"Directions") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Address book",@""),NSLocalizedString(@"Current GPS Position",@"Driving directions current GPS POS"),nil];
	[action showInView:[self superview]];
}
- (void)willMoveToSuperview:(UIView*)view {
	GPSController *g=[[xGPSAppDelegate gpsmanager] GetCurrentGPS];
	
	if(g.gps_data.fix.mode>1) {
		float lat=g.gps_data.fix.latitude;
		float lon=g.gps_data.fix.longitude;
		
		[currentPosition release];
		currentPosition=[[NSString alloc] initWithFormat:@"%f,%f",lat,lon];
		from.text=NSLocalizedString(@"Current Position",@"");
	} else {
		//from.text=@"Ch. du Marais 9 1031 Mex";
		from.text=@"";
	}
	to.text=@"";
	//to.text=@"Grand vigne, Vufflens-la-Ville, Switzerland";
	//to.text=@"Zermatt, Switzerland";
//	to.text=@"Rte de Marteley 1302 Vufflens";
}
- (void)didMoveToSuperview {
	GPSController *g=[[xGPSAppDelegate gpsmanager] GetCurrentGPS];
	if(g.gps_data.fix.mode>1)
		[to becomeFirstResponder];
	else
		[from becomeFirstResponder];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	//0 cities,1 directions,2 cancel
	switch(buttonIndex) {
		case 0: {
			ABPeoplePickerNavigationController *picker =
			[[ABPeoplePickerNavigationController alloc] init];
			picker.peoplePickerDelegate = self;
			picker.displayedProperties=[NSArray arrayWithObject:[NSNumber numberWithInt: kABPersonAddressProperty]];
			[controller presentModalViewController:picker animated:YES];
			[picker release];			
		}break;
		case 1: {
			GPSController *g=[[xGPSAppDelegate gpsmanager] GetCurrentGPS];
			
			if(g.gps_data.fix.mode>1) {
				float lat=g.gps_data.fix.latitude;
				float lon=g.gps_data.fix.longitude;
				
				[currentPosition release];
				currentPosition=[[NSString alloc] initWithFormat:@"%f,%f",lat,lon];
				bookmarkClicked.text=NSLocalizedString(@"Current Position",@"");
			} else {
				UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"Unable to get the GPS position. The GPS is not currently giving any position information.",@"GPS Dir Pos error message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
				[alert show];
			}
		}break;
	}
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
	
	[controller dismissModalViewControllerAnimated:YES];
	
	bookmarkClicked.text=out;
	
	if(bookmarkClicked==from)
		[to becomeFirstResponder];
	else
		[self searchBarSearchButtonClicked:to];
	
	bookmarkClicked=nil;
	
	CFRelease(dic);
	CFRelease(multi);
	
	
	
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
