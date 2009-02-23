//
//  MapsDownloadDetailsViewController.m
//  xGPS
//
//  Created by Mathieu on 23.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapsDownloadDetailsViewController.h"
#import "xGPSAppDelegate.h"

@implementation MapsDownloadDetailsViewController


- (id)initWithStyle:(UITableViewStyle)style delegate:(id<MapsDownloadDetailsDelegate>)_delegate {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.title=NSLocalizedString(@"Map details",@"");
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Download",@"Download button")
																	  style: UIBarButtonItemStyleDone target:self
																	 action:@selector(startDownloadButton)];
		self.navigationItem.rightBarButtonItem = addButton;
		delegate=_delegate;
		[addButton release];
    }
    return self;
}
-(void) startDownloadButton {
	if(txtName.text.length==0) {
		UIAlertView * hotSheet = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"Maps Download",@"")
								  message:[NSString stringWithFormat:NSLocalizedString(@"Please enter a name for your map.",@""),10]
								  delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss")
								  otherButtonTitles:nil];
		
		[hotSheet show];	
		[txtName becomeFirstResponder];
		return;
	}
	[delegate gotName:txtName.text andZoomLevel:(int)(slideZoom.value+0.5)];
	[self.navigationController popViewControllerAnimated:YES];
}

// Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	 // Return YES for supported orientations
	 return YES;
 }
 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0: return NSLocalizedString(@"Map name",@"");
		case 1: return NSLocalizedString(@"Zoom level to download",@"");
		default:
			return nil;
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch(section) {
		case 1: return [NSString stringWithFormat:NSLocalizedString(@"The zoom level %d corresponds to the most detailed zoom level",@""),[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsMapType]==0 ? 0 : 2];
		default:
			return nil;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section==0)
    return 1;
	else 
		return 2;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier;
    
	switch(indexPath.section) {
		case 0: CellIdentifier=@"name"; break;
		case 1: if(indexPath.row==1) CellIdentifier=@"zoom"; else CellIdentifier=@"zoomlbl"; break;
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		switch(indexPath.section) {
			case 0:
				txtName=[[UITextField alloc] initWithFrame:CGRectMake(10,(cell.frame.size.height-22)/2.0,cell.frame.size.width-20,22)];
				txtName.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				[cell.contentView addSubview:txtName];
				[txtName becomeFirstResponder];
				txtName.delegate=self;
				break;
			case 1:
				switch(indexPath.row) {
					case 1:
						slideZoom=[[UISlider alloc] initWithFrame:CGRectMake(10,(cell.frame.size.height-30)/2.0,cell.frame.size.width-30,30)];
						slideZoom.frame=CGRectMake((cell.frame.size.width-slideZoom.frame.size.width)/2.0, (cell.frame.size.height-slideZoom.frame.size.height)/2.0, slideZoom.frame.size.width, slideZoom.frame.size.height);
						if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsMapType]==0)
							slideZoom.minimumValue=0;
						else
							slideZoom.minimumValue=2;		
						[slideZoom addTarget:self action:@selector(zoomChanged) forControlEvents:UIControlEventValueChanged];
						slideZoom.value=slideZoom.minimumValue;
						slideZoom.maximumValue=17;
						slideZoom.autoresizingMask=UIViewAutoresizingFlexibleWidth;
						[cell.contentView addSubview:slideZoom];
						break;
					case 0:
						if(slideZoom!=nil)
							cell.text=[NSString stringWithFormat:NSLocalizedString(@"Zoom level: %d",@""),(int)(slideZoom.value+0.5)];
						else
							cell.text=[NSString stringWithFormat:NSLocalizedString(@"Zoom level: %d",@""),[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsMapType]==0 ? 0 : 2];
						break;
				}break;
		}
    }
    
    // Set up the cell...
	
    return cell;
}
-(void)zoomChanged {
	UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
	if(cell!=nil){
		cell.text=[NSString stringWithFormat:NSLocalizedString(@"Zoom level: %d",@""),(int)(slideZoom.value+0.5)];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0)
		[txtName becomeFirstResponder];
}



- (void)dealloc {
	[txtName release];
	[slideZoom release];
    [super dealloc];
}


@end

