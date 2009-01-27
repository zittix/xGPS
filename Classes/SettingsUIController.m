//
//  SettingsUIController.m
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsUIController.h"
#import "xGPSAppDelegate.h"
#import "TitleValueCell.h"
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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"General",@"");
			break;
		case 1:
			return NSLocalizedString(@"Night Mode",@"");
			break;
		default:
			return nil;
			break;
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return NSLocalizedString(@"The night mode allows you to concentrate yourself on the road by not being disturbed by the iPhone screen brightness. The colors are darker and the screen brightness will be set to the minimum.",@"");
			break;
		default:
			return nil;
			break;
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0: return 3;
		case 1: return 1+([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled] && [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled] ? 2 : 0)+([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled] ? 1 : 0);
	}
	return 0;
}

-(void)switchSpeedChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsShowSpeed];
}
-(void)switchBluePointChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsUseGPSBall];
}
-(void)switchWrongWayChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsWrongWayHidden];
}

-(void)switchNightMode:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsNightModeEnabled];
	NSArray *toInsert;
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled]) {
		toInsert=[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1],nil];
		
		
	} else {
		toInsert=[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1],nil];
		
	}
	if(sender.on) {
		
		[self.tableView beginUpdates];
		[self.tableView insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationBottom];
		[self.tableView endUpdates];
	} else {
		
		[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationBottom];
		[self.tableView endUpdates];
	}
	
}
-(void)switchTimer:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsTimerNightEnabled];
	NSArray *toInsert=[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1],nil];
	
	if(sender.on) {
		
		[self.tableView beginUpdates];
		[self.tableView insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationBottom];
		[self.tableView endUpdates];
	} else {
		
		[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationBottom];
		[self.tableView endUpdates];
	}
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier;
	switch (indexPath.section) {
		case 0: 
			switch(indexPath.row) {
				case 0: CellIdentifier=@"showspeed"; break;
				case 1: CellIdentifier=@"usebluepin"; break;
				case 2: CellIdentifier=@"wrongwayhidden"; break;
			} break;
		case 1: 
			switch(indexPath.row) {
				case 0: CellIdentifier=@"enablednightmode"; break;
				case 1: CellIdentifier=@"usetimer"; break;
				case 2: CellIdentifier=@"starttime"; break;
				case 3: CellIdentifier=@"endtime"; break;
			} break;
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		switch (indexPath.section) {
			case 0:  {
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
						cell.text=NSLocalizedString(@"Blue dot for position",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchBluePointChanged:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseGPSBall];
						break;
					}
					case 2: {
						cell.text=NSLocalizedString(@"Wrong Way hidden",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchWrongWayChanged:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsWrongWayHidden];
						break;
					}
				}break;
			case 1: {
				switch(indexPath.row) {
					case 0: {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						cell.text=NSLocalizedString(@"Enable night mode",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchNightMode:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled];
						break;
					}
					case 1: {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						cell.text=NSLocalizedString(@"Enable timer",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchTimer:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled];
						break;
					}	
					case 2: {
						TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell=cell2;
						cell2.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						cell2.title=NSLocalizedString(@"Start time",@"");
						cell2.value=@"20:00";
						break;
					}	
					case 3: {
						TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell=cell2;
						cell2.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						cell2.title=NSLocalizedString(@"Stop time",@"");
						cell2.value=@"7:00";
						break;
					}	
				}
			}
			}
		}
    }
	else {
		switch (indexPath.section) {
			case 0:
				switch(indexPath.row) {
					case 0: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowSpeed];
						break;
					}
					case 1: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseGPSBall];
						break;
					}
					case 2: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsWrongWayHidden];
						break;
					}
				} break;
			case 1:
				switch(indexPath.row) {
					case 0: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled];
						break;
					}
					case 1: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled];
						break;
					}
					case 2: {
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						break;
					}
					case 3: {
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						break;
					}
				} break;
		}
	}
	self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
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

