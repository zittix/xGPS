//
//  SettingsGeneralController.m
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsGPXController.h"
#import "xGPSAppDelegate.h"
#import "TitleValueCell.h"
#import "GPXLogger.h"
@implementation SettingsGPXController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.title=NSLocalizedString(@"GPX Logging",@"");
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
-(float)getsize {
	NSString *path = [NSString stringWithCString:getGPXFilename()];
	//NSLog(@"Getting file size %@",path);
	NSFileManager * fm = [NSFileManager defaultManager];
	
	NSDictionary *fattrs = [fm fileAttributesAtPath:path traverseLink:YES];
	NSNumber *nb=[fattrs objectForKey:NSFileSize];
	//NSLog(@"file size: %f",[nb unsignedLongLongValue]/1024.0/1024.0);
	return [nb unsignedLongLongValue]/1024.0/1024.0;		
}
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return 2;
	}
	return 0;
}

-(void)switchDirSearch:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsSaveDirSearch];
	
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
		switch (section) {
			case 0:
				return NSLocalizedString(@"When GPX logging is activated, all your moves are recorded into a file in the GPX format. The file can then be used on a computer to visualize the track.",@"");
				break;
			default:
				return nil;
				break;
		}
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier;
	switch(indexPath.row) {
		case 0: CellIdentifier=@"filesize"; break;
		case 1: CellIdentifier=@"deletefile"; break;
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		switch(indexPath.row) {
			case 0: {
				TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle =UITableViewCellSelectionStyleNone;
				cell2.title=NSLocalizedString(@"Log file size",@"");
				cell2.value=[NSString stringWithFormat:NSLocalizedString(@"%.1f MB",@"Size of the map, MB=MegaBytes"),[self getsize]];
				cell=cell2;
			} break;
			case 1: {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.text=NSLocalizedString(@"Delete GPX Log file",@"");
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle=UITableViewCellSelectionStyleBlue;
			}
		}
    }
	else {
		switch(indexPath.row) {
			case 0: {
				((TitleValueCell*) cell).value=[NSString stringWithFormat:NSLocalizedString(@"%.1f MB",@"Size of the map, MB=MegaBytes"),[self getsize]];
				break;
			}
		}
	}
    return cell;
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex==0) {
		stopGPXLogEngine();
		NSString *path = [NSString stringWithCString:getGPXFilename()];
		
		NSFileManager * fm = [NSFileManager defaultManager];

		NSError *err;
		[fm removeItemAtPath:path error:&err];

		if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsGPSLog])
			startGPXLogEngine();
		[self.tableView reloadData];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==1) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		UIActionSheet *act=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete all the recorded tracks ?",@"Delete tracks") delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"Yes",@"Yes") otherButtonTitles:NSLocalizedString(@"No",@"No"),nil];
		[act showInView:self.view];
	}
}






- (void)dealloc {
    [super dealloc];
}


@end

