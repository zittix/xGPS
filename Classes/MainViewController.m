//
//  FirstViewController.m
//  xGPS
//
//  Created by Mathieu on 7/30/08.
//  Copyright Xwaves 2008. All rights reserved.
//

#import "MainViewController.h"
#import "Position.h"
#import "xGPSAppDelegate.h"
#import "GPXLogger.h"
@implementation MainViewController

@synthesize mapview;

@synthesize tiledb;
-(id)init {
	if((self=[super init])) {
	//NSLog(@"MainView controller init...");
	tiledb=[xGPSAppDelegate tiledb];
	gpsPos=[[PositionObj alloc] init];
	[[xGPSAppDelegate gpsmanager] setDelegate:self];
	}
		return self;
}
- (void)loadView {
	//NSLog(@"MainView controller loadView...");
	self.title=@"xGPS";
	
	//Set the View to a UIView
	viewRect=[[UIScreen mainScreen] applicationFrame];
	viewRect.size.height=viewRect.size.height-44.0f;

	self.view=[[UIView alloc] initWithFrame:viewRect];
		
	//self.navigationController.navigationBarHidden=YES;
	self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
	self.view.autoresizesSubviews=YES;

	
	//Inside the view:

	//self.view.backgroundColor=[UIColor blueColor];
	mapview=[[MapView alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,viewRect.size.height-44.0) withDB:tiledb];
	mapview.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:mapview];
	zoomview=[[ZoomView alloc] initWithFrame:CGRectMake(10,10,100,100) withDelegate:mapview];
	[self.view addSubview:zoomview];
	speedview=[[SpeedView alloc] initWithFrame:CGRectMake(2.0f,viewRect.size.height-95.0f-2.0f-44.0f,92.0f,100.0f)];
	[speedview setSpeed:0];

	//[self.view addSubview:speedview];
	speedview.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0,viewRect.size.height-44.0f,viewRect.size.width,44.0f)];
	[self.view addSubview:toolbar];
	[self.view addSubview:speedview];
	btnEnableGPS=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Enable GPS",@"Enable GPS Button") style:UIBarButtonItemStyleBordered target:self action:@selector(gpsEnableBtnPressed:)];
	toolbar.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	btnSettings=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings",@"Settings Button") style:UIBarButtonItemStyleBordered target:self action:@selector(settingsBtnPressed:)];
	btnSearch=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBtnPressed:)];
	btnSearch.style=UIBarButtonItemStyleBordered;
	space1=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	space2=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	NSArray *btn=[NSArray arrayWithObjects:btnSearch,space2,btnSettings,nil];
	[toolbar setItems:btn animated:YES];	
	//92x100
		settingsController=[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped withMap:mapview withDB:tiledb];
		searchPlacesView=[[SearchPlacesView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,[[UIScreen mainScreen] applicationFrame].size.height) andController:self.navigationController andMap:mapview];
		searchPlacesView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	searchPlacesView.autoresizesSubviews=YES;
	signalView=[[GPSSignalView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-52,5,47,40)];
	signalView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self.view addSubview:signalView];
	[signalView setQuality:0];
	speedview.hidden=YES;
	
	
}
-(void)hideSpeed {
	[UIView beginAnimations:nil context:nil];
	//[speedview removeFromSuperview];
	speedview.hidden=YES;
	[UIView commitAnimations];
}
-(void)showSpeed {
	[UIView beginAnimations:nil context:nil];
	//[self.view addSubview:speedview];
	speedview.hidden=NO;
	[UIView commitAnimations];
}
- (void)dealloc {
	[super dealloc];
	[mapview release];
	[zoomview release];
	[speedview release];
	[toolbar release];
	[btnEnableGPS release];
	[btnSettings release];
	[btnSearch release];
	[space1 release];
	[space2 release];
	[settingsController release];
	[signalView release];
	[searchPlacesView release];
	[gpsPos release];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:YES];
	self.title=NSLocalizedString(@"Map","Map");
	[[NSUserDefaults standardUserDefaults] setFloat:[mapview getCurrentPos].x forKey:kSettingsLastPosX];
	[[NSUserDefaults standardUserDefaults] setFloat:[mapview getCurrentPos].y forKey:kSettingsLastPosY];

}
-(void)viewWillAppear:(BOOL)animated {
	self.title=@"xGPS";
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense) {
		NSArray *btn=[NSArray arrayWithObjects:btnEnableGPS,space1,btnSearch,space2,btnSettings,nil];
		[toolbar setItems:btn animated:YES];	
		if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled) {
			btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
			btnEnableGPS.style=UIBarButtonItemStyleDone;
			[mapview setHasGPSPos:YES];
			[mapview setGPSTracking:YES];
			[mapview refreshMap];
			[self showSpeed];
		} else{
			[mapview setHasGPSPos:NO];
			btnEnableGPS.style=UIBarButtonItemStyleBordered;
			btnEnableGPS.title=NSLocalizedString(@"Enable GPS",@"Enable GPS Button");
		}
	}else {
		NSArray *btn=[NSArray arrayWithObjects:btnSearch,space2,btnSettings,nil];
		[toolbar setItems:btn animated:YES];	
		[mapview setHasGPSPos:NO];
		[mapview refreshMap];
	}	
	
	if(![[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsConditionsUse] isEqualToString:vSettingsConditionsUse]) {
		[[NSUserDefaults standardUserDefaults] setObject:vSettingsConditionsUse forKey:kSettingsConditionsUse];
		
	if(licenseView==nil) {
		licenseView=[[LicenseViewController alloc] init];
	}
	[self presentModalViewController:licenseView animated:YES];
	}
	PositionObj *p=[PositionObj positionWithX:[[NSUserDefaults standardUserDefaults] floatForKey:kSettingsLastPosX] y:[[NSUserDefaults standardUserDefaults] floatForKey:kSettingsLastPosY]];
	if(p.x==0.0f && p.y==0.0f) {
		p.x=46.5833333;
		p.y=6.55;
	}
	mapview.pos=p;
	mapview.mapRotationEnabled=![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapRotation];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewDidAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[mapview refreshMap];
	//NSLog(@"Frame org (%f,%f) size (%f,%f)",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
	//NSLog(@"CENTER size: %f %f of view",self.view.center.x,self.view.center.y);

	//[UIView beginAnimations:nil context:nil];	
	//[UIView setAnimationDidStopSelector:@selector(endRotation:::)];
	//float sx=self.view.frame.size.width/mapview.frame.size.height;
	//float sy=(self.view.frame.size.height-44.0)/mapview.frame.size.width;
	//mapview.transform=CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI/2.0),sy,sx);
	//mapview.transform=CGAffineTransformMakeRotation(M_PI/2.0);
	//mapview.frame=CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-44.0);
	//[UIView commitAnimations];

	[super viewDidAppear:animated];
}
-(void) endRotation:(NSString*)animationID finished:(BOOL)finished context:(NSString*)context {
	[self.navigationController pushViewController:settingsController animated:YES];
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[mapview refreshMap];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
-(void)gpsEnableBtnPressed:(id)sender {
	
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled && btnEnableGPS.style!=UIBarButtonItemStyleDone) {
		NSLog(@"Enabled et pas done");
		[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] DisableGPS];
		btnEnableGPS.style=UIBarButtonItemStyleBordered;
		[mapview setGPSTracking:NO];
	}
	else if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled && btnEnableGPS.style==UIBarButtonItemStyleDone){
		btnEnableGPS.style=UIBarButtonItemStyleBordered;
		NSLog(@"Enabled et done");
		[mapview setGPSTracking:NO];
		
	} else {
			NSLog(@"Disabled");
			[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] EnableGPS];
			btnEnableGPS.style=UIBarButtonItemStyleDone;
			[mapview setGPSTracking:YES];
	}
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled) {
		btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
		[self showSpeed];

		[mapview setHasGPSPos:YES];

	} else{
		[mapview setHasGPSPos:NO];
		[mapview refreshMap];
		[self hideSpeed];
		[signalView setQuality:0];
		btnEnableGPS.style=UIBarButtonItemStyleBordered;
		btnEnableGPS.title=NSLocalizedString(@"Enable GPS",@"Enable GPS Button");
	}
}
-(void)settingsBtnPressed:(id)sender {
	[UIView beginAnimations:nil context:nil];	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(endRotation:finished:context:)];
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[UIView commitAnimations];
	
	
}
-(void)searchBtnPressed:(id)sender {
	//Let the user choose between directions and place search
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline]) {
		UIAlertView *msg=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"You cannot do a search request while you are in the offline mode. You can switch off the offline mode by tapping the Settings button.",@"Error search offline") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[msg show];
		return;
	}
	
	UIActionSheet *action=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Search for:",@"Search actionsheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Places / Cities",@"Search for places"),NSLocalizedString(@"Driving directions",@"Driving directions"),nil];
	[action showFromToolbar:toolbar];
}
-(void)cancelSearchPressed:(id)sender {
	[UIView beginAnimations:nil context:nil];	
	self.navigationController.navigationBarHidden=YES;
	[searchPlacesView removeFromSuperview];
	[UIView commitAnimations];
}
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	//0 cities,1 directions,2 cancel
	switch(buttonIndex) {
		case 0: {
			[UIView beginAnimations:nil context:nil];
			[self.view addSubview:searchPlacesView];
			[UIView commitAnimations];
		}break;
		case 1: {
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"This feature will be implemented in a future version.",@"Not yet implemented message.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
			[alert show];

		}break;
	}
}
- (void)gpsChanged:(ChangedState*)msg {
	//NSLog(@"Receiving change for state: %@",[ChangedState stringForState:msg.state]);
	switch(msg.state) {
		case VERSION_CHANGE:
			break;
		case CONNECTION_CHANGE:
			if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[toolbar items] count]!=5) {
				NSArray *btn=[NSArray arrayWithObjects:btnEnableGPS,space1,btnSearch,space2,btnSettings,nil];
				[toolbar setItems:btn animated:YES];		
			}else if(![[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[toolbar items] count]!=3) {
				NSArray *btn=[NSArray arrayWithObjects:btnSearch,space2,btnSettings,nil];
				[toolbar setItems:btn animated:YES];	
				[mapview setHasGPSPos:NO];
				[signalView setQuality:0];
				[self hideSpeed];
			}

			break;
		case POS: {
			if(gpsPos==nil) return;
			gpsPos.x=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.latitude;
			gpsPos.y=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.longitude;
			[mapview updateCurrentPos:gpsPos];
			[mapview setHasGPSPos:YES];
			logGPXPoint([[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.latitude, [[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.longitude, [[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.altitude, [[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.speed, [[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.mode, [[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].satellites_used, [[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.time);
			
			break;
		}case SPEED: {
			float speedms=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.speed;
			//TODO: settings based
			speedms*=3.6f;
			if(speedms>3)
			[speedview setSpeed:speedms];
		}break;
		case STATE_CHANGE:
			if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled) {
				[self showSpeed];
				btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
				[mapview setGPSTracking:YES];
				btnEnableGPS.style=UIBarButtonItemStyleDone;
			} else{
				[mapview setHasGPSPos:NO];
				[self hideSpeed];
				btnEnableGPS.style=UIBarButtonItemStyleBordered;
				btnEnableGPS.title=NSLocalizedString(@"Enable GPS",@"Enable GPS Button");
				[signalView setQuality:0];
				[mapview setGPSTracking:NO];
			}
			break;
		case SIGNAL_QUALITY:
			[signalView setQuality:[[xGPSAppDelegate gpsmanager] GetCurrentGPS].signalQuality];
			break;
		case SERIAL:
			break;
	}
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);

	return YES;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


@end
