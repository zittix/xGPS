//
//  SettingsGeneralController.m
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsGPSController.h"
#import "xGPSAppDelegate.h"
#import "TitleValueCell.h"
@implementation SettingsGPSController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.title=NSLocalizedString(@"GPS",@"");
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
    
    NSString *id;
	switch(indexPath.row) {
		case 0:	id=@"sectGPS_gpstype"; break;
		case 1:	id=@"sectGPS_gpsstate"; break;
		case 2:	id=@"sectGPS_gpsreset"; break;
		case 3:	id=@"sectGPS_gpsdetails"; break;
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
		switch(indexPath.section) {
			case 0: switch(indexPath.row) {
				case 0: {
					TitleValueCell* cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:id] autorelease];
					cell=cell2;
					cell2.title=NSLocalizedString(@"GPS to use",@"Title in setting for gps to use");	
					cell2.value=[[xGPSAppDelegate gpsmanager] GetCurrentGPSName];
					
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				} break;
				case 1:	{
					TitleValueCell* cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:id] autorelease];
					cell=cell2;					
					cell2.title=NSLocalizedString(@"GPS state",@"Title in setting for gps state");
					
					
					if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense)
						cell2.value=NSLocalizedString(@"Connected",@"GPS State");	
					else if(![[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense)
						cell2.value=NSLocalizedString(@"Disconnected",@"GPS State");	
					else
						cell2.value=NSLocalizedString(@"No License",@"GPS State");	
				} break;
				case 2:
					cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:id] autorelease];
					cell.selectionStyle=UITableViewCellSelectionStyleBlue;
					
					cell.text=NSLocalizedString(@"Reset GPS",@"Reset GPS Button");
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					cell.accessoryAction=@selector(resetGPS:);
					break;
				case 3:
					cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:id] autorelease];
					cell.selectionStyle=UITableViewCellSelectionStyleBlue;
					
					cell.text=NSLocalizedString(@"GPS Information",@"");
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					break;
					
			}break;
				
		}
		
    }
	else {
		switch(indexPath.row) {
			case 0: {
				((TitleValueCell*)cell).value=[[xGPSAppDelegate gpsmanager] GetCurrentGPSName];
			} break;
			case 1:	{
				if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense)
					((TitleValueCell*)cell).value=NSLocalizedString(@"Connected",@"GPS State");	
				else if(![[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense)
					((TitleValueCell*)cell).value=NSLocalizedString(@"Disconnected",@"GPS State");	
				else
					((TitleValueCell*)cell).value=NSLocalizedString(@"No License",@"GPS State");	
				
			} break;
		}
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Use the Reset GPS option to restart the GPS when it gives a completly wrong position or if it does not respond anymore.",@"");
			break;
		default:
			return nil;
			break;
	}
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section==0 && indexPath.row==2) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] resetGPS];
	}else if(indexPath.section==0 && indexPath.row==0) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		if(gpsselector==nil) {
			gpsselector=[[GPSSelectorViewController alloc] initWithStyle:UITableViewStylePlain];
		}
		[self.navigationController pushViewController:gpsselector animated:YES];
		
	}else if(indexPath.section==0 && indexPath.row==3) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[APPDELEGATE.navControllerMain showGPSDetails];
		
	}
}






- (void)dealloc {
    [super dealloc];
}


@end

