//
//  SettingsViewController.m
//  xGPS
//
//  Created by Mathieu on 8/31/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "SettingsViewController.h"
#import "TitleValueCell.h"
#import "xGPSAppDelegate.h"
#include "GPXLogger.h"
@implementation SettingsViewController
#define VALUE_COLOR [UIColor colorWithRed:0.235 green:0.2549 blue:0.49019 alpha:1]

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		self.title=NSLocalizedString(@"Settings",@"Settings Button");
	}
	return self;
}


- (void)dealloc {
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0: return NSLocalizedString(@"Maps",@"Maps title in settings");
		case 1: return NSLocalizedString(@"GPS Device",@"GPS Device title in settings");
		case 2: return NSLocalizedString(@"Driving directions",@"Driving directions");
		case 3: return NSLocalizedString(@"General",@"General title in settings");
			
		default: return @"";
	}
}*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0: return 3;
		case 1: return 7;
		default: return 0;
	}
}
-(void)showGPSSelector:(id)sender {
	if(gpsselector==nil) {
		gpsselector=[[GPSSelectorViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	[self.navigationController pushViewController:gpsselector animated:YES];
}

-(void)showMapsTypeSelector:(id)parent {
	
}
-(void)switchSleepMode:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSleepMode];
	[UIApplication sharedApplication].idleTimerDisabled=sender.on;
}
-(void)switchOfflineChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsMapsOffline];
}
-(void)switchRotationChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:!sender.on forKey:kSettingsMapRotation];
}
-(void)switchUnit:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSpeedUnit];
}

-(void)switchGPSLoggingChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsGPSLog];
	if(sender.on)
		startGPXLogEngine();
	else
		stopGPXLogEngine();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *id=@"";
	switch(indexPath.section) {
		case 0: switch(indexPath.row) {
			case 0:	id=@"sectQuick_offline"; break;
			case 1:	id=@"sectQuick_autorot"; break;
			case 2:	id=@"sectQuick_gpx"; break;
		} break;
		case 1: {
			switch(indexPath.row) {
				case 0:	id=@"general"; break;
				case 1:	id=@"maps"; break;
				case 2:	id=@"gps"; break;
				case 3:	id=@"locations"; break;
				case 4:	id=@"driving"; break;
				case 5:	id=@"gpx"; break;
				case 6:	id=@"ui"; break;
			}break;
		}
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:id] autorelease];
		cell.selectionStyle =UITableViewCellSelectionStyleNone;
		
		switch(indexPath.section) {
			case 0: switch(indexPath.row) {
				case 0: {
					cell.text=NSLocalizedString(@"Offline mode",@"Offline mode");
					UISwitch *value;
					
					value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
					value.tag = 1;
					[value addTarget:self action:@selector(switchOfflineChanged:) forControlEvents:UIControlEventValueChanged];
					value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
					[cell.contentView addSubview:value];
					//[value release];
					value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline];
					break;
				}
				case 1:	
				{
					cell.text=NSLocalizedString(@"Map auto-rotation",@"Map auto-rotation");
					UISwitch *value;
					
					value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
					value.tag = 1;
					[value addTarget:self action:@selector(switchRotationChanged:) forControlEvents:UIControlEventValueChanged];
					value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
					[cell.contentView addSubview:value];
					value.on=![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapRotation];
					//[value release];
					break;
				}
					
				case 2:	
				{
					cell.text=NSLocalizedString(@"GPX Logging",@"Activate GPX Logging");
					UISwitch *value;
					
					value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
					value.tag = 1;
					[value addTarget:self action:@selector(switchGPSLoggingChanged:) forControlEvents:UIControlEventValueChanged];
					value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
					[cell.contentView addSubview:value];
					value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsGPSLog];
					//[value release];
				}
				break;
			} break;
			case 1: {
				switch(indexPath.row) {
					case 0: {
						cell.text=NSLocalizedString(@"General",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					} break;
					case 1:	{
						cell.text=NSLocalizedString(@"Maps",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					} break;
					case 2:	{
						cell.text=NSLocalizedString(@"GPS",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					} break;
					case 3:
						cell.text=NSLocalizedString(@"Locations",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

						break;
					case 4:
						cell.text=NSLocalizedString(@"Driving Directions",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						
						break;
					case 5:
						cell.text=NSLocalizedString(@"GPX Logging",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						
						break;
					case 6:
						cell.text=NSLocalizedString(@"User Interface",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						break;
				}break;
			} break;
		}
		
	} else {
		switch(indexPath.section) {
			case 0: switch(indexPath.row) {
				case 0:	
				{
					((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline];
				}
					break;
				case 1:	
				{
					((UISwitch*)[cell viewWithTag:1]).on=![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapRotation];
				}
					break;
				case 2:	
				{
					((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsGPSLog];
				}
					break;
			}
		}
	}
	
	
	// Configure the cell
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==1 && indexPath.row==0) {
		if(generalsettings==nil)
			generalsettings=[[SettingsGeneralController alloc] initWithStyle:UITableViewStyleGrouped];
		[self.navigationController pushViewController:generalsettings animated:YES];
	} else if(indexPath.section==1 && indexPath.row==6) {
		if(uisettings==nil)
			uisettings=[[SettingsUIController alloc] initWithStyle:UITableViewStyleGrouped];
		[self.navigationController pushViewController:uisettings animated:YES];
			
	}else if(indexPath.section==1 && indexPath.row==1) {
		if(mapssettings==nil)
			mapssettings=[[SettingsMapsController alloc] initWithStyle:UITableViewStyleGrouped];
		[self.navigationController pushViewController:mapssettings animated:YES];
		
	}
}


- (void)viewDidLoad {
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[self.tableView reloadData];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

@end

