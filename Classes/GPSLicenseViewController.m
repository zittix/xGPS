//
//  GPSLicenseViewController.m
//  xGPS
//
//  Created by Mathieu on 9/17/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "GPSLicenseViewController.h"
#import "xGPSAppDelegate.h"

@implementation GPSLicenseViewController


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.title=NSLocalizedString(@"License number",@"License number title");
		value = [[UITextField alloc] initWithFrame:CGRectMake(115.0, 10.0, 170.0, 25.0)];
		value.keyboardType=UIKeyboardTypeNamePhonePad;
		value.returnKeyType=UIReturnKeySend;
		value.delegate=self;
		value.autocorrectionType=UITextAutocorrectionTypeNo;
		CGRect viewRect=[[UIScreen mainScreen] applicationFrame];
		viewRect.origin.y=0;
		progress=[[ProgressView alloc] initWithFrame:viewRect];
		[progress setStatusText:NSLocalizedString(@"Verifying license number...",@"Verify license text")];
		[progress hideCancelButton];
		[progress hideProgressText];
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
	[value release];
	[progress release];
}
-(void)setLicenseValue:(NSString*)val {
	value.text=val;	
}

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:NSLocalizedString(@"License number for %@",@"Title section in license view"),[[xGPSAppDelegate gpsmanager] GetCurrentGPS].name];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
-(void)checkSerialThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSNumber *res=[NSNumber numberWithBool:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] checkLicense:value.text]];
	[self performSelectorOnMainThread:@selector(FinishedChecking:) withObject:res waitUntilDone:YES];
	[pool release];
}

-(void)FinishedChecking:(NSNumber*)valid {
	UIAlertView *alert=[UIAlertView alloc];
	NSString *msg;
	if([valid boolValue])
		msg=NSLocalizedString(@"Your license number is valid. You can now use the selected GPS.",@"Confirm valid license");
	else 
		msg=NSLocalizedString(@"Your license number is invalid. Please verify and retry",@"Confirm invalid license");
	alert=[alert initWithTitle:NSLocalizedString(@"License checking",@"Title of the message box of the result of the checking..") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
	[alert show];
	[progress hide];
	NSLog(@"Final checking license connected:%d",[[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected);
	if([valid boolValue])
		[self.navigationController popViewControllerAnimated:YES];
	else
		[value becomeFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	//Check serial in a thread
	[value resignFirstResponder];
	[progress setProgress:.1];
	[progress showFrom:self.view];
	[NSThread detachNewThreadSelector:@selector(checkSerialThread) toTarget:self withObject:nil];
	return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
		UILabel *label;
		
		label = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 80.0, 25.0)] autorelease];
		label.tag = 2;
		label.font = [UIFont boldSystemFontOfSize:16.0];
		label.textAlignment = UITextAlignmentLeft;
		label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
		[cell.contentView addSubview:label];
		
		
		
		value.tag = 1;
		
		value.font = [UIFont systemFontOfSize:16.0];
		value.textAlignment = UITextAlignmentLeft;
		value.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		value.textColor=[UIColor darkGrayColor];
		[cell.contentView addSubview:value];
		label.text=NSLocalizedString(@"License:",@"License number title for cell");	
		
    }
    // Configure the cell
    return cell;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[value becomeFirstResponder];
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].license !=nil) {
		value.text=[[xGPSAppDelegate gpsmanager] GetCurrentGPS].license;
	} else {
		value.text=@"";
	}
	
}



@end

