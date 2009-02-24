//
//  GPSDetailsViewController.m
//  xGPS
//
//  Created by Mathieu on 27.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GPSDetailsViewController.h"
#import "TitleValueCell.h"
#import "xGPSAppDelegate.h"
@implementation GPSDetailsViewController



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	CGRect viewRect=[[UIScreen mainScreen] applicationFrame];
	viewRect.size.height=viewRect.size.height-44.0f;
	viewRect.origin.y=44.0f;
	UINavigationBar *bar=[[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,44)];
	_tableView=[[UITableView alloc] initWithFrame:viewRect style:UITableViewStyleGrouped];
	bar.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	UINavigationItem *item=[[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"GPS Information",@"")];
	item.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
	[bar pushNavigationItem:item animated:NO];
	[item release];
	_tableView.delegate=self;
	_tableView.dataSource=self;
	_tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[self.view addSubview:bar];
	[self.view addSubview:_tableView];
	self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[bar release];
}

-(UITableView*)tableView {
	return _tableView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	switch (section) {
		case 1:
		{
			return 40.0f;
		}
	}
	return 0;
}
- (NSString *) urlencode: (NSString *) url encoding:(NSString*)enc
{
	CFStringEncoding cEnc= kCFStringEncodingUTF8;
	
	if([enc isEqualToString: @"latin1"] )
		cEnc=kCFStringEncodingISOLatin1;
	
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, CFSTR("?=&+/'"), cEnc);
	return [result autorelease];
}
-(void)updateData {
	[self.tableView reloadData];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
		switch (section) {
			case 1:
			{
				UIView *cont=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,40)];
				
				//UIButton *btnSMS=[UIButton buttonWithType:UIButtonTypeRoundedRect];
				//[btnSMS setTitle:NSLocalizedString(@"Send by SMS",@"") forState:UIControlStateNormal];
				UIButton *btnEmail=[UIButton buttonWithType:UIButtonTypeRoundedRect];
				[btnEmail setTitle:NSLocalizedString(@"Send by Email",@"") forState:UIControlStateNormal];
				//btnSMS.frame=CGRectMake(10,0,(cont.frame.size.width-30)/2.0,40);
				btnEmail.frame=CGRectMake(10,0,(cont.frame.size.width-20),40);
				//[cont addSubview:btnSMS];
				[cont addSubview:btnEmail];
				cont.backgroundColor=[UIColor clearColor];
				cont.autoresizingMask=UIViewAutoresizingFlexibleWidth;
				//btnSMS.autoresizingMask=UIViewAutoresizingFlexibleWidth;
				btnEmail.autoresizingMask=UIViewAutoresizingFlexibleWidth;
				//[btnSMS addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
				[btnEmail addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
				return [cont autorelease];
			}break;
			default:
				return nil;
				break;
		}
}
-(NSString*)getGPSString {
	return [NSString stringWithFormat:@"%@\n%@: %f°\n%@: %f°\n%@: %f m",NSLocalizedString(@"My GPS position is:",@""),NSLocalizedString(@"Latitude",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.latitude,NSLocalizedString(@"Longitude",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.longitude,NSLocalizedString(@"Altitude",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.altitude];
}
-(void)sendSMS {
	NSString *urls=[NSString stringWithFormat:@"sms:?body=%@",[self urlencode:[self getGPSString] encoding:@"utf8"]];
	NSURL *url=[NSURL URLWithString:urls];
	[APPDELEGATE openURL:url];
}
-(void)sendEmail {
	NSString *urls=[NSString stringWithFormat:@"mailto:?subject=%@&body=%@",[self urlencode:NSLocalizedString(@"My GPS Position",@"") encoding:@"utf8"],[self urlencode:[self getGPSString] encoding:@"utf8"]];
	NSURL *url=[NSURL URLWithString:urls];
	//NSLog(@"%@",urls);
	[APPDELEGATE openURL:url];
	
}
-(void)close {
	[self dismissModalViewControllerAnimated:YES];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier;
	switch(indexPath.section) {
		case 0:
			switch(indexPath.row) {
				case 0: CellIdentifier=@"lat"; break;
				case 1: CellIdentifier=@"lon"; break;
				case 2: CellIdentifier=@"alt"; break;
				case 3: CellIdentifier=@"speed"; break;
			}
	}
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		switch(indexPath.section) {
			case 0:
				switch(indexPath.row) {
					case 0: {
						TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle =UITableViewCellSelectionStyleNone;
						cell2.title=NSLocalizedString(@"Latitude",@"");
						cell2.value=[NSString stringWithFormat:NSLocalizedString(@"%f °",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.latitude];
						cell=cell2;
					} break;
					case 1: {
						TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle =UITableViewCellSelectionStyleNone;
						cell2.title=NSLocalizedString(@"Longitude",@"");
						cell2.value=[NSString stringWithFormat:NSLocalizedString(@"%f °",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.longitude];
						cell=cell2;			
					} break;
					case 2: {
						TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle =UITableViewCellSelectionStyleNone;
						cell2.title=NSLocalizedString(@"Altitude",@"");
						cell2.value=[NSString stringWithFormat:NSLocalizedString(@"%f m",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.altitude];
						cell=cell2;
					} break;
					case 3: {
						TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle =UITableViewCellSelectionStyleNone;
						cell2.title=NSLocalizedString(@"Speed",@"");
						if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit])
							cell2.value=[NSString stringWithFormat:NSLocalizedString(@"%f mph",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.speed*3.6*0.62150404];
						else
							cell2.value=[NSString stringWithFormat:NSLocalizedString(@"%f km/h",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.speed*3.6];
						cell=cell2;
					} break;
				}break;
			case 1:
				switch(indexPath.row) {
					case 0: {
						TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle =UITableViewCellSelectionStyleNone;
						cell2.title=NSLocalizedString(@"Latitude",@"");
						cell2.value=[NSString stringWithFormat:NSLocalizedString(@"%f °",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.latitude];
						cell=cell2;
					} break;
				}
		}
    }
	else {
		switch(indexPath.section) {
			case 0:
				switch(indexPath.row) {
					case 0: {
						((TitleValueCell*) cell).value=[NSString stringWithFormat:NSLocalizedString(@"%f °",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.latitude];
						break;
					}
					case 1: {
						((TitleValueCell*) cell).value=[NSString stringWithFormat:NSLocalizedString(@"%f °",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.longitude];
						break;
					}
					case 2: {
						((TitleValueCell*) cell).value=[NSString stringWithFormat:NSLocalizedString(@"%f m",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.altitude];
						break;
					}
					case 3: {
						if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit])
							((TitleValueCell*) cell).value=[NSString stringWithFormat:NSLocalizedString(@"%f mph",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.speed*3.6*0.62150404];
						else
							((TitleValueCell*) cell).value=[NSString stringWithFormat:NSLocalizedString(@"%f km/h",@""),APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.speed*3.6];
						break;
					}
				}break;
		}
	}
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0: return 4;
		case 1: return 0;
	}
	return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0: return NSLocalizedString(@"GPS Information",@"");
		case 1: return nil;
	}
	return nil;
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


- (void)dealloc {
	[_tableView release];
	[self.view release];
    [super dealloc];
}


@end
