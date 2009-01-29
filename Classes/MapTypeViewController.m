//
//  MapTypeViewController.m
//  xGPS
//
//  Created by Mathieu on 9/23/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "MapTypeViewController.h"
#import "xGPSAppDelegate.h"


@implementation MapTypeViewController
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.title=NSLocalizedString(@"Map Type",@"");
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier;
	CellIdentifier=[NSString stringWithFormat:@"%d",indexPath.row];
	
	int type=APPDELEGATE.tiledb.type;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];

		if(type==indexPath.row)
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
		else
			cell.accessoryType=UITableViewCellAccessoryNone;
		switch(indexPath.row) {
			case 0:
				cell.text=NSLocalizedString(@"Google Maps",@"Map"); break;
			case 2:
				cell.text=NSLocalizedString(@"Google Maps Satellite",@"Satellite"); break;
			case 1:
				cell.text=NSLocalizedString(@"Google Maps Terrain",@"Map Terrain"); break;
			case 3:
				cell.text=NSLocalizedString(@"Google Maps Hybrid",@"Map Hybrid"); break;
			
		}
    }
	else {
		if(type==indexPath.row)			
			cell.accessoryType=UITableViewCellAccessoryCheckmark;
		else
			cell.accessoryType=UITableViewCellAccessoryNone;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:kSettingsMapType];
	
	for(int i=0;i<[tableView numberOfRowsInSection:0];i++) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i	inSection:0]];
		cell.accessoryType=UITableViewCellAccessoryNone;
	}
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType=UITableViewCellAccessoryCheckmark;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end
