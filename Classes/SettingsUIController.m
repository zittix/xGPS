//
//  SettingsUIController.m
//  xGPS
//
//  Created by Mathieu on 01.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SettingsUIController.h"
#import "xGPSAppDelegate.h"
#import "TitleValueCell.h"
@implementation SettingsUIController


- (id)init {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super init]) {
		self.navigationItem.title=NSLocalizedString(@"User Interface",@"");
		
		self.view=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
		[self.view release];
		self.view.autoresizesSubviews=YES;
		tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
		tableView.dataSource=self;
		tableView.delegate=self;
		
		self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		toolbarPicker=[[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width,44)];
		toolbarPicker.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		
		UIBarButtonItem *space=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *btnDone=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(setTime)];
		[toolbarPicker setItems:[NSArray arrayWithObjects:space,btnDone,nil] animated:NO];
		[space release];
		[btnDone release];
		pickerTime=[[UIDatePicker alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height+44,self.view.frame.size.width,210)];
		pickerTime.datePickerMode=UIDatePickerModeTime;
		pickerTime.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		pickerTime.autoresizesSubviews=YES;
		dummyView=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-254)];
		dummyView.backgroundColor=[UIColor blackColor];
		dummyView.alpha=0;
		dummyView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		pickerTime.minuteInterval=5;
				
		[self.view addSubview:tableView];
		
    }
    return self;
}

-(void) setTime {
	//editingTime
	
	
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateFormat:@"HH:mm"];
	NSString *date=[dateFormatter stringFromDate:pickerTime.date];
	[dateFormatter release];
	if(editingTime==0)
		[[NSUserDefaults standardUserDefaults] setObject:date forKey:kSettingsTimerNightStart];
	else
		[[NSUserDefaults standardUserDefaults] setObject:date forKey:kSettingsTimerNightStop];
	[self.tableView reloadData];
	
	[UIView beginAnimations:nil context:nil];
	dummyView.alpha=0;
	
	tableView.scrollEnabled=YES;
	toolbarPicker.frame=CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width,44);
	pickerTime.frame=CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width,210);
	tableView.frame=CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
	[toolbarPicker removeFromSuperview];
	[pickerTime removeFromSuperview];
	[dummyView removeFromSuperview];
	[UIView commitAnimations];
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"General",@"");
			break;
		case 1:
			return NSLocalizedString(@"Night Mode",@"");
			break;
		default:
			return nil;
			break;
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return NSLocalizedString(@"The night mode allows you to concentrate on the road by not being disturbed by the iPhone screen brightness. The colors are darker and the screen brightness will be set to the minimum.",@"");
			break;
		default:
			return nil;
			break;
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0: return 4;
		case 1: return 1+([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled] && [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled] ? 2 : 0)+([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled] ? 1 : 0);
	}
	return 0;
}

-(void)switchSpeedChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsShowSpeed];
}
-(void)switchBluePointChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsUseGPSBall];
}
-(void)switchWrongWayChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsWrongWayHidden];
}
-(void)switchLargeFontChanged:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsLargeFont];
}

-(void)switchNightMode:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsNightModeEnabled];
	NSArray *toInsert;
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled]) {
		toInsert=[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1],nil];
		
		
	} else {
		toInsert=[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1],nil];
		
	}
	if(sender.on) {
		
		[self.tableView beginUpdates];
		[self.tableView insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationBottom];
		[self.tableView endUpdates];
	} else {
		
		[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationBottom];
		[self.tableView endUpdates];
	}
	
}
-(void)switchTimer:(UISwitch*)sender {
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kSettingsTimerNightEnabled];
	NSArray *toInsert=[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1],nil];
	
	if(sender.on) {
		
		[self.tableView beginUpdates];
		[self.tableView insertRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationBottom];
		[self.tableView endUpdates];
	} else {
		
		[self.tableView beginUpdates];
		[self.tableView deleteRowsAtIndexPaths:toInsert withRowAnimation:UITableViewRowAnimationBottom];
		[self.tableView endUpdates];
	}
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier;
	switch (indexPath.section) {
		case 0: 
			switch(indexPath.row) {
				case 0: CellIdentifier=@"showspeed"; break;
				case 1: CellIdentifier=@"usebluepin"; break;
				case 2: CellIdentifier=@"wrongwayhidden"; break;
				case 3: CellIdentifier=@"largefont"; break;
			} break;
		case 1: 
			switch(indexPath.row) {
				case 0: CellIdentifier=@"enablednightmode"; break;
				case 1: CellIdentifier=@"usetimer"; break;
				case 2: CellIdentifier=@"starttime"; break;
				case 3: CellIdentifier=@"endtime"; break;
			} break;
	}
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		switch (indexPath.section) {
			case 0:  {
				cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.selectionStyle=UITableViewCellSelectionStyleNone;
				switch(indexPath.row) {
					case 0: {
						cell.text=NSLocalizedString(@"Show Speedometer",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchSpeedChanged:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowSpeed];
						break;
					}
					case 1: {
						cell.text=NSLocalizedString(@"Blue dot for position",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchBluePointChanged:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseGPSBall];
						break;
					}
					case 2: {
						cell.text=NSLocalizedString(@"Wrong Way hidden",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchWrongWayChanged:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsWrongWayHidden];
						break;
					}
					case 3: {
						cell.text=NSLocalizedString(@"Large font size",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchLargeFontChanged:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsLargeFont];
						break;
					}
				}break;
			case 1: {
				switch(indexPath.row) {
					case 0: {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						cell.text=NSLocalizedString(@"Enable night mode",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchNightMode:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled];
						break;
					}
					case 1: {
						cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell.selectionStyle=UITableViewCellSelectionStyleNone;
						cell.text=NSLocalizedString(@"Enable timer",@"");
						UISwitch *value;
						
						value = [[[UISwitch alloc] initWithFrame:CGRectMake(215.0, 8.0, 70.0, 25.0)] autorelease];
						value.tag = 1;
						[value addTarget:self action:@selector(switchTimer:) forControlEvents:UIControlEventValueChanged];
						value.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
						[cell.contentView addSubview:value];
						value.on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled];
						break;
					}	
					case 2: {
						TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell=cell2;
						cell2.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						cell2.title=NSLocalizedString(@"Start time",@"");
						//cell2.value=@"20:00";
						NSString * timeInt=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsTimerNightStart];
						if(timeInt==nil) 
							timeInt=@"20:00";
						
						cell2.value=timeInt;
						
						break;
					}	
					case 3: {
						TitleValueCell *cell2 = [[[TitleValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
						cell=cell2;
						cell2.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						cell2.title=NSLocalizedString(@"Stop time",@"");
						NSString * timeInt=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsTimerNightStop];
						if(timeInt==nil) 
							timeInt=@"7:00";
						cell2.value=timeInt;
						break;
					}	
				}
			}
			}
		}
    }
	else {
		switch (indexPath.section) {
			case 0:
				switch(indexPath.row) {
					case 0: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowSpeed];
						break;
					}
					case 1: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsUseGPSBall];
						break;
					}
					case 2: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsWrongWayHidden];
						break;
					}
					case 3: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsLargeFont];
						break;
					}
						
				} break;
			case 1:
				switch(indexPath.row) {
					case 0: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled];
						break;
					}
					case 1: {
						((UISwitch*)[cell viewWithTag:1]).on=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled];
						break;
					}
					case 2: {
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						NSString * timeInt=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsTimerNightStart];
						if(timeInt==nil) 
							timeInt=@"20:00";
						((TitleValueCell*)cell).value=timeInt;
						break;
					}
					case 3: {
						cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
						NSString * timeInt=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsTimerNightStop];
						if(timeInt==nil) 
							timeInt=@"7:00";
						((TitleValueCell*)cell).value=timeInt;
						break;
					}
				} break;
		}
	}
	self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    return cell;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==1) {
		if(indexPath.row==2 || indexPath.row==3) {
			editingTime=indexPath.row-2;
			dummyView.alpha=0;
			[self.view addSubview:pickerTime];
			[self.view addSubview:toolbarPicker];
			[self.view addSubview:dummyView];
			
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
			
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateStyle:NSDateFormatterNoStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			[dateFormatter setDateFormat:@"HH:mm"];
			
			NSString * timeInt=nil;
			
			if(editingTime==0)
				timeInt=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsTimerNightStart];
			else
				timeInt=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsTimerNightStop];
			
			if(timeInt==nil && editingTime==0) 
				timeInt=@"20:00";
			else if(timeInt==nil && editingTime==1) 
				timeInt=@"7:00";
			
			NSDate *date=[dateFormatter dateFromString:timeInt];
			
			
			[dateFormatter release];
			
			pickerTime.date=date;
			
			
			[UIView beginAnimations:nil context:nil];
			dummyView.alpha=0.7;
			tableView.scrollEnabled=NO;
			toolbarPicker.frame=CGRectMake(0,self.view.frame.size.height-254,self.view.frame.size.width,44);
			pickerTime.frame=CGRectMake(0,self.view.frame.size.height-210,self.view.frame.size.width,210);
			dummyView.frame=tableView.frame=CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-254);
			[UIView commitAnimations];
		}
	}
}






- (void)dealloc {
	[tableView release];
	[pickerTime release];
	[dummyView release];
	[toolbarPicker release];
    [super dealloc];
}

@synthesize tableView;
@end

