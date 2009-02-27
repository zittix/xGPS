//
//  SettingsGeneralController.m
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsMapsController.h"
#import "xGPSAppDelegate.h"
#import "TitleValueCell.h"
#import "MapsManagerView.h"
@implementation SettingsMapsController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.title=NSLocalizedString(@"Maps",@"");
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
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"The maps size will also grow when you browse a part of a map you have not already downloaded.",@"");
			break;
		default:
			return nil;
			break;
	}
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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

-(void)switchSleepMode:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSleepMode];
	
}
-(void)switchUnit:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSpeedUnit];
	[self.tableView reloadData];
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier;
	switch(indexPath.row) {
			case 0:	CellIdentifier=@"sectMaps_manage"; break;
			
			case 1:	CellIdentifier=@"sectMaps_size"; break;
			case 2:	CellIdentifier=@"sectMaps_delete"; break;
			case 3:	CellIdentifier=@"sectMaps_type"; break;
		}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		switch(indexPath.section) {
			case 0: {
				switch(indexPath.row) {
					case 0:
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle =UITableViewCellSelectionStyleNone;
						cell.text=NSLocalizedString(@"Download maps",@"");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						cell.accessoryAction=@selector(showMapsManager:);
						break;
					case 1:	
					{
						TitleValueCell* cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell=cell2;				
						cell2.value=[NSString stringWithFormat:NSLocalizedString(@"%.1f MB",@"Size of the map, MB=MegaBytes"),[xGPSAppDelegate tiledb].mapsize];
						cell2.title=NSLocalizedString(@"Downloaded maps size",@"Downloaded maps size of settings view");
					}
						break;
					case 2:	
					{
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle =UITableViewCellSelectionStyleNone;
						cell.text=NSLocalizedString(@"Delete downloaded maps",@"Delete downloaded maps in settings");
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						cell.selectionStyle=UITableViewCellSelectionStyleBlue;
					}
						break;
					case 3:	
					{
						TitleValueCell* cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell=cell2;
						cell2.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						switch(APPDELEGATE.tiledb.type) {
							case 0:
								cell2.value=NSLocalizedString(@"Google Maps",@"Map"); break;
							case 2:
								cell2.value=NSLocalizedString(@"GMaps Satellite",@"Satellite"); break;
							case 3:
								cell2.value=NSLocalizedString(@"GMaps Hybrid",@"Map Hybrid"); break;
							case 1:
								cell2.value=NSLocalizedString(@"GMaps Terrain",@"Map Terrain"); break;
						}
						cell2.title=NSLocalizedString(@"Maps type",@"");
						
					}
						break;
				}
			}
		}
		
    }
	else {
		switch(indexPath.row) {
			
			case 1:	
			{
				//NSLog(@"Reload size");
				((TitleValueCell*)cell).value=[NSString stringWithFormat:NSLocalizedString(@"%.1f MB",@"Size of the map, MB=MegaBytes"),[xGPSAppDelegate tiledb].mapsize];
			}
				break;
			case 3:	
			{
				switch(APPDELEGATE.tiledb.type) {
					case 0:
						((TitleValueCell*)cell).value=NSLocalizedString(@"Google Maps",@"Map"); break;
					case 2:
						((TitleValueCell*)cell).value=NSLocalizedString(@"GMaps Satellite",@"Satellite"); break;
					case 3:
						((TitleValueCell*)cell).value=NSLocalizedString(@"GMaps Hybrid",@"Map Hybrid"); break;
					case 1:
						((TitleValueCell*)cell).value=NSLocalizedString(@"GMaps Terrain",@"Map Terrain"); break;

				}
			}
			break;
		}
	}
    return cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex==0) {
		[[xGPSAppDelegate tiledb] flushMaps];
		[self.tableView reloadData];
	}
}

-(void)showMapsManager:(id)sender {
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline]) {
		UIAlertView *msg=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"You cannot download maps while you are in the offline mode.",@"Error download maps offline") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[msg show];
	}else{
		

			MapsManagerView *mapsmanager=[[MapsManagerView alloc] initWithDB:APPDELEGATE.tiledb];
		
	
		[self.navigationController pushViewController:mapsmanager animated:YES];
		
		PositionObj *p=[[PositionObj alloc] init];
		p.x=[[NSUserDefaults standardUserDefaults] doubleForKey:kSettingsLastPosX];
		p.y=[[NSUserDefaults standardUserDefaults] doubleForKey:kSettingsLastPosY];
		[mapsmanager updateCurrentPos:p];
		[mapsmanager release];
		[p release];
	}
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0 && indexPath.row==0) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self showMapsManager:self];
	} else if(indexPath.section==0 && indexPath.row==3) {
		if(maptype==nil)
			maptype=[[MapTypeViewController alloc] init];
		[self.navigationController pushViewController:maptype animated:YES];
	}else if(indexPath.section==0 && indexPath.row==2) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		UIActionSheet *act=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete all the downloaded maps ?",@"Delete downloaded maps question") delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Yes",@"Yes") otherButtonTitles:NSLocalizedString(@"No",@"No"),nil];
		[act showInView:self.view];
	}
}






- (void)dealloc {
	[maptype release];
    [super dealloc];
}


@end

