//
//  SettingsGeneralController.m
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsGeneralController.h"
#import "xGPSAppDelegate.h"
#import "TitleValueCell.h"
@implementation SettingsGeneralController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.title=NSLocalizedString(@"General",@"");
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
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0:
		case 1:
		case 2:
			return 1;
		case 3:
			return 2;
	}
	return 0;
}

-(void)switchSleepMode:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSleepMode];
	
}
-(void)switchUnit:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSpeedUnit];
	[self.tableView reloadData];
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
		switch (section) {
			case 0:
				return NSLocalizedString(@"When activated, it disables the sleep mode such that the screen is always on.",@"");
				break;
			case 1:
				if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit])
				return NSLocalizedString(@"Distances and speed will be showed with the mile unit (mph and miles).",@"");
					else
				return NSLocalizedString(@"Distances and speed will be showed with the meter unit (km/h and meters).",@"");
				break;
			case 2:
				return NSLocalizedString(@"The language setting is used to localize the driving directions, the maps and the place/city search results.",@"");
				break;
			default:
				return nil;
				break;
		}
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier;
	switch(indexPath.section) {
		case 0: CellIdentifier=@"sectGen_Idle"; break;
		case 1: CellIdentifier=@"sectGen_speedunit"; break;
		case 2: CellIdentifier=@"sectGen_Lang"; break;
		case 3: 
			switch(indexPath.row) {
				case 0:	CellIdentifier=@"sectGen_about"; break;
				case 1:	CellIdentifier=@"sectGen_ver"; break;
			}
			break;	
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		switch(indexPath.section) {
			case 0: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle =UITableViewCellSelectionStyleNone;
				cell.text=NSLocalizedString(@"Prevent Sleep Mode",@"Prevent Sleep Mode");
				UISwitch *value;
				
				value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
				value.tag = 1;
				[value addTarget:self action:@selector(switchSleepMode:) forControlEvents:UIControlEventValueChanged];
				value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
				[cell.contentView addSubview:value];
				value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSleepMode];
				//[value release];
			} break;
			case 1: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle =UITableViewCellSelectionStyleNone;
				cell.text=NSLocalizedString(@"Use Miles unit",@"Use Miles unit");
				UISwitch *value;
				
				value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
				value.tag = 1;
				[value addTarget:self action:@selector(switchUnit:) forControlEvents:UIControlEventValueChanged];
				value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
				[cell.contentView addSubview:value];
				value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit];
				//[value release];
				
			} break;
			case 2: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				
				cell.text=NSLocalizedString(@"Language",@"");
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
			}break;
			case 3: {
				switch(indexPath.row) {
					case 0: {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						
						cell.text=NSLocalizedString(@"About xGPS",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					}break;
					case 1: {
						TitleValueCell* cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell=cell2;						
						cell2.title=NSLocalizedString(@"Version",@"Version string");
						cell2.value=@VERSION;	
						
					}break;
				}
			}
		}
    }
	else {
		switch(indexPath.section) {
			case 0: {
				((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSleepMode];
				break;
			}
			case 1: {
				((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit];
				break;
			}
		}
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0 && indexPath.section==3) {
		if(aboutView==nil)
			aboutView=[[AboutViewController alloc] init];
		[self.navigationController pushViewController:aboutView animated:YES];
	} else if(indexPath.row==0 && indexPath.section==2) {
		if(langView==nil)
			langView=[[LanguageViewController alloc] init];
		[self.navigationController pushViewController:langView animated:YES];
	}
}






- (void)dealloc {
    [super dealloc];
}


@end

