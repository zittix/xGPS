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
#import "HomeAddressViewController.h";
#import <MediaPlayer/MediaPlayer.h>
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
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return 4;
		case 1:
		case 2:
		case 3:
		case 4:
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
-(void)switchVoiceInstr:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsEnableVoiceInstr];
	
}
-(void)switchVoiceBip:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsDisableVoiceBip];
	
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Voice instructions work only when the language in General settings is set to English.",@"");
			break;
		case 1:
			return NSLocalizedString(@"When activated, all the searched driving directions are saved in the bookmarks.",@"");
			break;
		case 2:
			return NSLocalizedString(@"Your home address will be used to get driving directions to your home when the Home button is pressed.",@"");
			break;
		case 4:
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
		case 0: if(indexPath.row==0) CellIdentifier=@"voicedir"; else if(indexPath.row==1) CellIdentifier=@"voicebip"; else  if(indexPath.row==2) CellIdentifier=@"volume"; else  if(indexPath.row==3) CellIdentifier=@"volumec"; break;
		case 1: CellIdentifier=@"savebookmarks"; break;
		case 2: CellIdentifier=@"homeaddress"; break;
		case 3: CellIdentifier=@"delbookmarks"; break;
		case 4: CellIdentifier=@"recomputedriving"; break;
			
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		switch(indexPath.section) {
			case 0: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle =UITableViewCellSelectionStyleNone;
				
				UISwitch *value;
				
				value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
				value.tag = 1;
				
				value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
				
				
				if(indexPath.row==0) {
					cell.text=NSLocalizedString(@"Voice Instructions",@"");
					value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsEnableVoiceInstr];
					[value addTarget:self action:@selector(switchVoiceInstr:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:value];
				} else if(indexPath.row==1) {
					cell.text=NSLocalizedString(@"Disable Beep",@"");
					value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDisableVoiceBip];
					[value addTarget:self action:@selector(switchVoiceBip:) forControlEvents:UIControlEventValueChanged];
					[cell.contentView addSubview:value];
				} else if(indexPath.row==2) {
					cell.text=NSLocalizedString(@"Volume",@"");
					MPVolumeView *volume=[[MPVolumeView alloc] initWithFrame:CGRectMake(100,(cell.frame.size.height-25)/2.0,cell.frame.size.width-110,25)];
					volume.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
					[volume sizeToFit];
					[cell.contentView addSubview:volume];
				}else if(indexPath.row==3) {
					cell.text=NSLocalizedString(@"Test Voice volume",@"");
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				}
				
			} break;
			case 1: {
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
			case 2: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.text=NSLocalizedString(@"Home Address",@"");
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle=UITableViewCellSelectionStyleBlue;
			} break;
			case 3: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.text=NSLocalizedString(@"Delete all bookmarks",@"");
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle=UITableViewCellSelectionStyleBlue;
			} break;
			case 4: {
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
				if(indexPath.row==0) {
					((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsEnableVoiceInstr];
				} else 	if(indexPath.row==1) {
					((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDisableVoiceBip];
				}
				
			}break;				
			case 1: {
				((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSaveDirSearch];
			}break;
			case 4: {
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
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==3) {
		UIActionSheet *act=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete all the saved bookmarks ?",@"Delete bookmarks") delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Yes",@"Yes") otherButtonTitles:NSLocalizedString(@"No",@"No"),nil];
		[act showInView:self.view];
	} else if(indexPath.section==2) {
		HomeAddressViewController *c=[[HomeAddressViewController alloc] initWithStyle:UITableViewStyleGrouped];
		[self.navigationController pushViewController:c animated:YES];
		[c release];
	} else if(indexPath.section==0 && indexPath.row==3) {
		SoundEvent *s;
		if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDisableVoiceBip])
			s=[[SoundEvent alloc] initWithText:@"In 200 meters, please turn left."];
		else
			s=[[SoundEvent alloc] initWithText:@"In 200 meters, please turn left." andSound:Sound_Announce];
		[APPDELEGATE.soundcontroller addSound:s];	
		[s release];
	}
}





- (void)dealloc {
    [super dealloc];
}


@end

