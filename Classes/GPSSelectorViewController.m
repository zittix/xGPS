//
//  GPSSelectorViewController.m
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "GPSSelectorViewController.h"
#import "xGPSAppDelegate.h"
@implementation GPSSelectorViewController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		self.navigationItem.title=NSLocalizedString(@"Pick a GPS",@"Title gps picker");
		gpsList=[[[xGPSAppDelegate gpsmanager] GetAllGPSNames] retain];
		waitingForLicense=NO;
    }
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [gpsList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d",indexPath.row+1];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		NSString* name=[gpsList objectForKey:[NSNumber numberWithInt:indexPath.row+1]];
		if(name!=nil)
			cell.text=name;
    }
    // Configure the cell
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	for(int i=0;i<[tableView numberOfRowsInSection:0];i++) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i	inSection:0]];
		cell.accessoryType=UITableViewCellAccessoryNone;
	}
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType=UITableViewCellAccessoryCheckmark;
	[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] stop];
	[[xGPSAppDelegate gpsmanager] setCurrentGPS:indexPath.row+1];
	if([[[xGPSAppDelegate gpsmanager] GetCurrentGPS] needLicense] && ![[[xGPSAppDelegate gpsmanager] GetCurrentGPS] validLicense]) {
		if(licenseView==nil){
			licenseView=[[GPSLicenseViewController alloc] initWithStyle:UITableViewStyleGrouped];
		}
		waitingForLicense=YES;
		[self.navigationController pushViewController:licenseView animated:YES];
	} else {
		if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense && ![[xGPSAppDelegate gpsmanager] GetCurrentGPS].started) {
			[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] start];
		}
		[self.navigationController popViewControllerAnimated:YES];
	}
}


/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	for(int i=0;i<[self.tableView numberOfRowsInSection:0];i++) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i	inSection:0]];
		cell.accessoryType=UITableViewCellAccessoryNone;
	}
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[xGPSAppDelegate gpsmanager].idGPS-1 inSection:0] ];
	cell.accessoryType=UITableViewCellAccessoryCheckmark;
	}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	if(waitingForLicense) {
		
		waitingForLicense=NO;
		
		if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense) {
		if(![[xGPSAppDelegate gpsmanager] GetCurrentGPS].started) {
			[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] start];
		}
		[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc {
    [super dealloc];
	[gpsList release];
	if(licenseView!=nil)
	[licenseView release];
}


@end

