//
//  SettingsViewController.m
//  xGPS
//
//  Created by Mathieu on 8/31/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "SettingsViewController.h"

#import "xGPSAppDelegate.h"
#include "GPXLogger.h"
@implementation SettingsViewController
#define VALUE_COLOR [UIColor colorWithRed:0.235 green:0.2549 blue:0.49019 alpha:1]

- (id)initWithStyle:(UITableViewStyle)style withMap:(MapView*)mapview withDB:(TileDB*)_db{
	if (self = [super initWithStyle:style]) {
		_mapview=mapview;
		db=_db;
		self.title=NSLocalizedString(@"Settings",@"Settings Button");
		//NSLog(@"View center: %f %f",self.view.center.x,self.view.center.y);
		enabled=YES;
	}
	return self;
}


- (void)dealloc {
	[super dealloc];
	if(mapsmanager!=nil) {
		[mapsmanager release];
	}
	if(gpsselector!=nil) {
		[gpsselector release];
	}
	if(dirLangView!=nil) {
		[dirLangView release];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0: return NSLocalizedString(@"Maps",@"Maps title in settings");
		case 1: return NSLocalizedString(@"GPS Device",@"GPS Device title in settings");
		case 2: return NSLocalizedString(@"Driving directions",@"Driving directions");
		case 3: return NSLocalizedString(@"General",@"General title in settings");
			
		default: return @"";
	}
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0: return 7;
		case 1: return 4;
		case 2: return 1;
		case 3: return 4;
		default: return 0;
	}
}
-(void)showMapsManager:(id)sender {
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline]) {
		UIAlertView *msg=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"You cannot download maps while you are in the offline mode.",@"Error download maps offline") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[msg show];
	}else{
		
		if(mapsmanager==nil) {
			mapsmanager=[[MapsManagerView alloc] initWithDB:db];
		}
		
		[self.navigationController pushViewController:mapsmanager animated:YES];
		[mapsmanager updateCurrentPos:[_mapview getCurrentPos]];
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
			case 0:	id=@"sectMaps_manage"; break;
			case 1:	id=@"sectMaps_type"; break;
			case 2:	id=@"sectMaps_size"; break;
			case 3:	id=@"sectMaps_delete"; break;
			case 4:	id=@"sectMaps_offline"; break;
			case 5:	id=@"sectMaps_receive"; break;
		} break;
		case 1: {
			switch(indexPath.row) {
				case 0:	id=@"sectGPS_gpstype"; break;
				case 1:	id=@"sectGPS_gpsstate"; break;
				case 2:	id=@"sectGPS_gpsreset"; break;
				case 3:	id=@"sectGPS_gpslog"; break;
			}break;
		}
		case 2: {
			switch(indexPath.row) {
				case 0:	id=@"sectDrvDir_lang"; break;
			}break;
		}
		case 3: {
			switch(indexPath.row) {
				case 0:	id=@"sectGen_about"; break;
				case 1:	id=@"sectGen_ver"; break;
				case 2:	id=@"sectGen_Idle"; break;
				case 3: id=@"sectGen_speedunit"; break;
			}break;
		}
	}
	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:id] autorelease];
		cell.selectionStyle =UITableViewCellSelectionStyleNone;
		switch(indexPath.section) {
			case 0: switch(indexPath.row) {
				case 0:
					cell.text=NSLocalizedString(@"Manage maps",@"Manage maps row in settings");
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					cell.accessoryAction=@selector(showMapsManager:);
					break;
				case 1:	
				{
					UILabel *label;
					UILabel *value;
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					cell.accessoryAction=@selector(showMapsTypeSelector:);
					label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 180.0, 25.0)] autorelease];
					label.tag = 2;
					label.font = [UIFont boldSystemFontOfSize:16.0];
					label.textAlignment = UITextAlignmentLeft;
					label.backgroundColor=[UIColor clearColor];
					label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
					value = [[[UILabel alloc] initWithFrame:CGRectMake(135.0, 10.0, 180.0, 25.0)] autorelease];
					value.tag = 1;
					
					value.font = [UIFont systemFontOfSize:16.0];
					value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
					value.backgroundColor=[UIColor clearColor];
					
					value.textColor=VALUE_COLOR;
					value.textAlignment=UITextAlignmentRight;
					value.text=@"Google Maps";
					[cell.contentView addSubview:value];
					label.text=NSLocalizedString(@"Maps type",@"Manage maps row in settings");
					[cell.contentView addSubview:label];
					//[label release];
					//[value release];
				}
					break;
				case 2:	
				{
					UILabel *label;
					UILabel *value;
					
					label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 180.0, 25.0)] autorelease];
					label.tag = 2;
					label.font = [UIFont boldSystemFontOfSize:16.0];
					label.textAlignment = UITextAlignmentLeft;
					label.backgroundColor=[UIColor clearColor];
					label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
					value = [[[UILabel alloc] initWithFrame:CGRectMake(135.0, 10.0, 180.0, 25.0)] autorelease];
					value.tag = 1;
					
					value.font = [UIFont systemFontOfSize:16.0];
					value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
					value.backgroundColor=[UIColor clearColor];
					
					value.textColor=VALUE_COLOR;
					value.textAlignment=UITextAlignmentRight;
					value.text=[NSString stringWithFormat:NSLocalizedString(@"%.1f MB",@"Size of the map, MB=MegaBytes"),[xGPSAppDelegate tiledb].mapsize];
					
					[cell.contentView addSubview:value];
					label.text=NSLocalizedString(@"Downloaded maps size",@"Downloaded maps size of settings view");
					[cell.contentView addSubview:label];
					//[label release];
					//[value release];
				}
					break;
				case 3:	
				{
					cell.text=NSLocalizedString(@"Delete downloaded maps",@"Delete downloaded maps in settings");
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle=UITableViewCellSelectionStyleBlue;
				}
					break;
				case 4: {
					cell.text=NSLocalizedString(@"Offline mode",@"Offline mode");
					UISwitch *value;
					
					value = [[[UISwitch alloc] initWithFrame:CGRectMake(220.0, 8.0, 70.0, 25.0)] autorelease];
					value.tag = 1;
					[value addTarget:self action:@selector(switchOfflineChanged:) forControlEvents:UIControlEventValueChanged];
					value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
					[cell.contentView addSubview:value];
					value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline];
					//[value release];
					
				}break;
				case 5: {
					cell.text=NSLocalizedString(@"Map auto-rotation",@"Map auto-rotation");
					UISwitch *value;
					
					value = [[[UISwitch alloc] initWithFrame:CGRectMake(220.0, 8.0, 70.0, 25.0)] autorelease];
					value.tag = 1;
					[value addTarget:self action:@selector(switchRotationChanged:) forControlEvents:UIControlEventValueChanged];
					value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
					[cell.contentView addSubview:value];
					value.on=![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapRotation];
					//[value release];
					
				}break;
				case 6: {
					cell.text=NSLocalizedString(@"Receive maps",@"Receive maps");
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				}break;
			} break;
			case 1: {
				switch(indexPath.row) {
					case 0: {
						UILabel *label;
						UILabel *value;
						
						label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0,150.0, 25.0)] autorelease];
						label.tag = 2;
						label.font = [UIFont boldSystemFontOfSize:16.0];
						label.textAlignment = UITextAlignmentLeft;
						label.backgroundColor=[UIColor clearColor];
						label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:label];
						
						
						value = [[[UILabel alloc] initWithFrame:CGRectMake(135.0, 10.0, 180.0, 25.0)] autorelease];
						value.tag = 1;
						
						value.font = [UIFont systemFontOfSize:16.0];
						value.backgroundColor=[UIColor clearColor];
						value.textColor=VALUE_COLOR;
						[cell.contentView addSubview:value];
						value.textAlignment=UITextAlignmentRight;
						label.text=NSLocalizedString(@"GPS to use",@"Title in setting for gps to use");	
						value.text=[[xGPSAppDelegate gpsmanager] GetCurrentGPSName];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						//[label release];
						//[value release];
					} break;
					case 1:	{
						UILabel *label;
						UILabel *value;
						
						label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 120.0, 25.0)] autorelease];
						label.tag = 2;
						label.font = [UIFont boldSystemFontOfSize:16.0];
						label.textAlignment = UITextAlignmentLeft;
						label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						
						
						[cell.contentView addSubview:label];
						
						value = [[[UILabel alloc] initWithFrame:CGRectMake(135.0, 10.0, 180.0, 25.0)] autorelease];
						value.tag = 1;
						
						value.font = [UIFont systemFontOfSize:16.0];
						value.textAlignment = UITextAlignmentLeft;
						
						value.textColor=VALUE_COLOR;
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						
						
						label.text=NSLocalizedString(@"GPS state",@"Title in setting for gps state");
						
						
						if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense)
							value.text=NSLocalizedString(@"Connected",@"GPS State");	
						else if(![[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense)
							value.text=NSLocalizedString(@"Disconnected",@"GPS State");	
						else
							value.text=NSLocalizedString(@"No License",@"GPS State");	
						
						value.textAlignment=UITextAlignmentRight;
						[cell.contentView addSubview:value];
						//[label release];
						//[value release];
					} break;
					case 2:
						cell.selectionStyle=UITableViewCellSelectionStyleBlue;
						
						cell.text=NSLocalizedString(@"Reset GPS",@"Reset GPS Button");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						cell.accessoryAction=@selector(resetGPS:);
						break;
						
					case 3: {
						cell.text=NSLocalizedString(@"GPX Logging",@"Activate GPX Logging");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(220.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchGPSLoggingChanged:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsGPSLog];
						//[value release];
						
					}
				}break;
			} break;
			case 2: {
				switch(indexPath.row) {
					case 0: {
						UILabel *label;
						UILabel *value;
						
						label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0,150.0, 25.0)] autorelease];
						label.tag = 2;
						label.font = [UIFont boldSystemFontOfSize:16.0];
						label.textAlignment = UITextAlignmentLeft;
						label.backgroundColor=[UIColor clearColor];
						label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:label];
						
						
						value = [[[UILabel alloc] initWithFrame:CGRectMake(135.0, 10.0, 180.0, 25.0)] autorelease];
						value.tag = 1;
						
						value.font = [UIFont systemFontOfSize:16.0];
						value.backgroundColor=[UIColor clearColor];
						value.textColor=VALUE_COLOR;
						[cell.contentView addSubview:value];
						value.textAlignment=UITextAlignmentRight;
						label.text=NSLocalizedString(@"Language",@"Language to use for driving directions");	
						NSString *lang=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
						value.text=@"English";
						if(lang!=nil) {
							if([lang isEqualToString:@"fr"])
								value.text=@"Français";
							else if([lang isEqualToString:@"de"])
								value.text=@"Deutsch";
							else if([lang isEqualToString:@"it"])
								value.text=@"Italiano";
							else if([lang isEqualToString:@"iw"])
								value.text=@"עברית";
							else if([lang isEqualToString:@"zh-TW"])
								value.text=@"繁體中文";
							
						}
						
						
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						//[label release];
						//[value release];
					} break;
				}
			}break;
			case 3: {
				switch(indexPath.row) {
					case 0: {
						cell.text=NSLocalizedString(@"About xGPS",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					} break;
					case 1: {
						UILabel *label;
						UILabel *value;
						
						label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 120.0, 25.0)] autorelease];
						label.tag = 2;
						label.font = [UIFont boldSystemFontOfSize:16.0];
						label.textAlignment = UITextAlignmentLeft;
						label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						
						
						[cell.contentView addSubview:label];
						
						value = [[[UILabel alloc] initWithFrame:CGRectMake(135.0, 10.0, 180.0, 25.0)] autorelease];
						value.tag = 1;
						
						value.font = [UIFont systemFontOfSize:16.0];
						value.textAlignment = UITextAlignmentLeft;
						
						value.textColor=VALUE_COLOR;
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						
						
						label.text=NSLocalizedString(@"Version",@"Version string");
						
						
						value.text=@"1.1.0 Test";	
						
						value.textAlignment=UITextAlignmentRight;
						[cell.contentView addSubview:value];
						//[label release];
						//[value release];
						
					} break;
					case 2: {
						cell.text=NSLocalizedString(@"Prevent Sleep Mode",@"Prevent Sleep Mode");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(220.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchSleepMode:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSleepMode];
						//[value release];
						
					}break;
					case 3: {
						cell.text=NSLocalizedString(@"Use Miles unit",@"Use Miles unit");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(220.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchUnit:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit];
						//[value release];
						
					}break;
				}
			}break;
		}
		
	} else {
		switch(indexPath.section) {
			case 0: switch(indexPath.row) {
				case 1:	
				{
					//TODO: load settings
				}
					break;
				case 2:	
				{
					((UILabel*)[cell viewWithTag:1]).text=[NSString stringWithFormat:NSLocalizedString(@"%.1f MB",@"Size of the map, MB=MegaBytes"),[xGPSAppDelegate tiledb].mapsize];
				}
					break;
				case 4:	
				{
					((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline];
					((UISwitch*)[cell viewWithTag:1]).enabled=enabled;
				}
					break;
			} break;
			case 1: {
				switch(indexPath.row) {
					case 0: {
						UILabel *value=(UILabel*)[cell.contentView viewWithTag:1];
						value.text=[[xGPSAppDelegate gpsmanager] GetCurrentGPSName];
					} break;
					case 1:	{
						UILabel *value=(UILabel*)[cell.contentView viewWithTag:1];
						//NSLog(@"Current gps name: %@",[[xGPSAppDelegate gpsmanager] GetCurrentGPS].name);
						//NSLog(@"Current gps state license: %d",[[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense);
						//NSLog(@"Current gps state connected: %d",[[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected);
						if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense)
							value.text=NSLocalizedString(@"Connected",@"GPS State");	
						else if(![[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense)
							value.text=NSLocalizedString(@"Disconnected",@"GPS State");	
						else
							value.text=NSLocalizedString(@"No License",@"GPS State");	
						
					} break;
				}
			} break;
			case 2: {
				switch(indexPath.row) {
					case 0: {
						UILabel *value=(UILabel*)[cell.contentView viewWithTag:1];	
						NSString *lang=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
						value.text=@"English";
						if(lang!=nil) {
							if([lang isEqualToString:@"fr"])
								value.text=@"Français";
							else if([lang isEqualToString:@"de"])
								value.text=@"Deutsch";
							else if([lang isEqualToString:@"it"])
								value.text=@"Italiano";
							else if([lang isEqualToString:@"iw"])
								value.text=@"עברית";
							else if([lang isEqualToString:@"zh-TW"])
								value.text=@"繁體中文";
						}
					} break;
				}
			}
		}	
	}
	
	
	// Configure the cell
	return cell;
}
-(void) setEnabled:(BOOL)v {
	[self.tableView setScrollEnabled:v];
	enabled=v;
	[self.tableView reloadData];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex==0) {
		[[xGPSAppDelegate tiledb] flushMaps];
		[self.tableView reloadData];
	}
}
-(void)showLangDirSelector:(id)sender {
#define picker_height 260.0f
	if(dirLangView==nil) {
		dirLangView=[[DirectionsLanguageViewController alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-picker_height,self.view.frame.size.width,picker_height+44.0f) andController:self];
	}
	//NSLog(@"Height: %f, y=%f height=%f",self.view.bounds.size.height,self.view.bounds.size.height-picker_height-44.0f,picker_height+44.0f);
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	//[self.navigationController presentModalViewController:dirLangView animated:YES];
	[UIView beginAnimations:nil context:nil];
	
	[self.view addSubview:dirLangView];
	[UIView commitAnimations];
	[self setEnabled:NO];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(!enabled) return;
	if(indexPath.section==0 && indexPath.row==0) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self showMapsManager:self];
	} else if(indexPath.section==1 && indexPath.row==2) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] resetGPS];
	}else if(indexPath.section==1 && indexPath.row==0) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self showGPSSelector:self];
	} else if(indexPath.section==0 && indexPath.row==1) {
		[self showMapsTypeSelector:self];	
	}else if(indexPath.section==0 && indexPath.row==3) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		UIActionSheet *act=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete all the downloaded maps ?",@"Delete downloaded maps question") delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Yes",@"Yes") otherButtonTitles:NSLocalizedString(@"No",@"No"),nil];
		[act showInView:self.view];
	}else if(indexPath.section==2 && indexPath.row==0) {
		[self showLangDirSelector:self];	
	}else if(indexPath.section==3 && indexPath.row==0) {
		if(aboutView==nil)
			aboutView=[[AboutViewController alloc] init];
		[self.navigationController pushViewController:aboutView animated:YES];
	}else if(indexPath.section==0 && indexPath.row==6) {
		if(receiverView==nil)
			receiverView=[[NetworkReceiverViewController alloc] init];
		[self.navigationController pushViewController:receiverView animated:YES];
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

