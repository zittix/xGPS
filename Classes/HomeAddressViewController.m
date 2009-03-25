//
//  HomeAddressViewController.m
//  xGPS
//
//  Created by Mathieu on 23.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HomeAddressViewController.h"
#import "xGPSAppDelegate.h"

@implementation HomeAddressViewController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.title=NSLocalizedString(@"Home Address",@"");
		txtHome=[[UITextField alloc] initWithFrame:CGRectMake(10,20, 200, 22)];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSUserDefaults standardUserDefaults] setObject:txtHome.text forKey:kSettingsHomeAddress];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString(@"Your home address",@"");
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[txtHome resignFirstResponder];
	[self viewWillDisappear:YES];
	[self.navigationController popViewControllerAnimated:YES];
	return NO;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier =nil;
    if(indexPath.row==0) 
		CellIdentifier=@"txthome";
	else
		CellIdentifier=@"ab";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if(indexPath.row==0) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle=UITableViewCellSelectionStyleNone;
			txtHome.frame=CGRectMake(10, (cell.frame.size.height-22)/2.0, cell.frame.size.width-30, 22);
			txtHome.clearButtonMode=UITextFieldViewModeAlways;
			[cell.contentView addSubview:txtHome];
			txtHome.delegate=self;
			NSString *a=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsHomeAddress];
			if(a==nil ||  [a length]==0)
				[txtHome becomeFirstResponder];
		} else {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.text=NSLocalizedString(@"Address book",@"");
			cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
		}
    }
	if(indexPath.row==0) {
		if(txtHome.text.length==0) {
		NSString *a=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsHomeAddress];
		txtHome.text= a==nil ? @"" : a;
		}
	}
    return cell;
}
-(void)showAB {
	ABPeoplePickerNavigationController *picker =
	[[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	picker.displayedProperties=[NSArray arrayWithObject:[NSNumber numberWithInt: kABPersonAddressProperty]];
	[self presentModalViewController:picker animated:YES];
	[picker release];	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row==0)
		[txtHome becomeFirstResponder];
	else{
		[self showAB];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
	
	ABMultiValueRef multi=ABRecordCopyValue(person,property);
	NSDictionary *dic=(NSDictionary*)ABMultiValueCopyValueAtIndex(multi,identifier);
	NSString *addr=@"";
	
	if([dic objectForKey:(NSString*)kABPersonAddressStreetKey]!=nil)
		addr=[NSString stringWithFormat:@"%@, ",[dic objectForKey:(NSString*)kABPersonAddressStreetKey]];
	if([dic objectForKey:(NSString*)kABPersonAddressCityKey]!=nil)
		addr=[NSString stringWithFormat:@"%@%@ ",addr,[dic objectForKey:(NSString*)kABPersonAddressCityKey]];
	if([dic objectForKey:(NSString*)kABPersonAddressStateKey]!=nil)
		addr=[NSString stringWithFormat:@"%@%@ ",addr,[dic objectForKey:(NSString*)kABPersonAddressStateKey]];
	if([dic objectForKey:(NSString*)kABPersonAddressZIPKey]!=nil)
		addr=[NSString stringWithFormat:@"%@%@ ",addr,[dic objectForKey:(NSString*)kABPersonAddressZIPKey]];
	if([dic objectForKey:(NSString*)kABPersonAddressCountryKey]!=nil)
		addr=[NSString stringWithFormat:@"%@%@",addr,[dic objectForKey:(NSString*)kABPersonAddressCountryKey]];
	txtHome.text=addr;
	[self dismissModalViewControllerAnimated:YES];

	
	
	CFRelease(dic);
	CFRelease(multi);
	
	
	
    return NO;
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}


- (void)dealloc {
	[txtHome release];
	[super dealloc];
}


@end

