//
//  SettingsGeneralController.m
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsDrivingDirectionsController.h"
#import "xGPSAppDelegate.h"
#import "TitleValueCell.h"
@implementation SettingsDrivingDirectionsController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.title=NSLocalizedString(@"Driving directions",@"");
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
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0:
		case 1:
		case 2:
			return 1;
	}
	return 0;
}

-(void)switchDirSearch:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSaveDirSearch];
	
}
-(void)switchDirRecompute:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsRecomputeDriving];
	
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"When activated, all the searched driving directions are saved in the bookmarks.",@"");
			break;
		case 2:
			return NSLocalizedString(@"When activated, the driving directions are recomputed when you are driving on the wrong way.",@"");
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
		case 0: CellIdentifier=@"savebookmarks"; break;
		case 1: CellIdentifier=@"delbookmarks"; break;
		case 2: CellIdentifier=@"recomputedriving"; break;
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		switch(indexPath.section) {
			case 0: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle =UITableViewCellSelectionStyleNone;
				cell.text=NSLocalizedString(@"Save in Bookmarks",@"");
				UISwitch *value;
				
				value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
				value.tag = 1;
				[value addTarget:self action:@selector(switchDirSearch:) forControlEvents:UIControlEventValueChanged];
				value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
				[cell.contentView addSubview:value];
				value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSaveDirSearch];
			} break;
			case 1: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.text=NSLocalizedString(@"Delete all bookmarks",@"");
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle=UITableViewCellSelectionStyleBlue;
			} break;
			case 2: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle =UITableViewCellSelectionStyleNone;
				cell.text=NSLocalizedString(@"Recompute itinerary",@"");
				UISwitch *value;
				
				value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
				value.tag = 1;
				[value addTarget:self action:@selector(switchDirRecompute:) forControlEvents:UIControlEventValueChanged];
				value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
				[cell.contentView addSubview:value];
				value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsRecomputeDriving];
			} break;
		}
    }
	else {
		switch(indexPath.section) {
			case 0: {
				((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSaveDirSearch];
			}break;
			case 2: {
				((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsRecomputeDriving];
			}break;
		}
	}
    return cell;
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex==0) {
		[APPDELEGATE.dirbookmarks deleteAllBookmarks];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==1) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		UIActionSheet *act=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete all the saved bookmarks ?",@"Delete bookmarks") delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Yes",@"Yes") otherButtonTitles:NSLocalizedString(@"No",@"No"),nil];
		[act showInView:self.view];
	}
}





- (void)dealloc {
    [super dealloc];
}


@end

