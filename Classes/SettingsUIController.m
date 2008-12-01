//
//  SettingsUIController.m
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsUIController.h"
#import "xGPSAppDelegate.h"

@implementation SettingsUIController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.title=NSLocalizedString(@"User Interface",@"");
    }
    return self;
}


/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(void)switchSpeedChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsShowSpeed];
}
-(void)switchBluePointChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsUseGPSBall];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier;
    switch(indexPath.row) {
		case 0: CellIdentifier=@"showspeed"; break;
		case 1: CellIdentifier=@"usebluepin"; break;
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		switch(indexPath.row) {
			 case 0: {
				cell.text=NSLocalizedString(@"Show Speedometer",@"");
				UISwitch *value;
				
				value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
				value.tag = 1;
				[value addTarget:self action:@selector(switchSpeedChanged:) forControlEvents:UIControlEventValueChanged];
				value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
				[cell.contentView addSubview:value];
				value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowSpeed];
				break;
			}
			case 1: {
				cell.text=NSLocalizedString(@"Blue point for position",@"");
				UISwitch *value;
				
				value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
				value.tag = 1;
				[value addTarget:self action:@selector(switchBluePointChanged:) forControlEvents:UIControlEventValueChanged];
				value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
				[cell.contentView addSubview:value];
				value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseGPSBall];
				break;
			}
		}
    }
	else {
		switch(indexPath.row) {
			case 0: {
				((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowSpeed];
				break;
			}
			case 1: {
				((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseGPSBall];
				break;
			}
		}
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}






- (void)dealloc {
    [super dealloc];
}


@end

