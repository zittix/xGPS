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
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"CellHome";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		txtHome=[[UITextField alloc] initWithFrame:CGRectMake(10, (cell.frame.size.height-22)/2.0, cell.frame.size.width-30, 22)];
		txtHome.clearButtonMode=UITextFieldViewModeAlways;
		[cell.contentView addSubview:txtHome];
		txtHome.delegate=self;
		[txtHome becomeFirstResponder];
    }
	NSString *a=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsHomeAddress];
    txtHome.text= a==nil ? @"" : a;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [txtHome becomeFirstResponder];
}



- (void)dealloc {
	[txtHome release];
	[super dealloc];
}


@end

