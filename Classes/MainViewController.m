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
@implementation MainViewController

@synthesize mapview;

@synthesize tiledb;
-(id)init {
	NSLog(@"MainView controller init...");
	tiledb=[xGPSAppDelegate tiledb];
	debug=[[UILabel alloc] initWithFrame:CGRectMake(40,0,290,50)];
	[[xGPSAppDelegate gpsmanager] setDelegate:self];
	
	
	return self;
}
- (void)loadView {
	NSLog(@"MainView controller loadView...");
	self.title=NSLocalizedString(@"Map","Map Title");
	
	//Set the View to a UIView
	viewRect=[[UIScreen mainScreen] applicationFrame];
	viewRect.size.height=viewRect.size.height-44.0f;

	self.view=[[UIView alloc] initWithFrame:viewRect];
		
	//self.navigationController.navigationBarHidden=YES;
	self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
	self.view.autoresizesSubviews=YES;
	NSLog(@"View center: %f %f",self.view.center.x,self.view.center.y);
	
	//Inside the view:

	self.view.backgroundColor=[UIColor blueColor];
	mapview=[[MapView alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,viewRect.size.height-44.0) withDB:tiledb];
	mapview.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:mapview];
	zoomview=[[ZoomView alloc] initWithFrame:CGRectMake(10,10,100,100) withDelegate:mapview];
	[self.view addSubview:zoomview];
	speedview=[[SpeedView alloc] initWithFrame:CGRectMake(2.0f,viewRect.size.height-44.0f-95.0f-2.0f,92.0f,100.0f)];
	[speedview setSpeed:0];
	[speedview setSpeedVisible:YES];
	[self.view addSubview:speedview];
	speedview.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
	toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0,viewRect.size.height-44.0f,viewRect.size.width,44.0f)];
	[self.view addSubview:toolbar];
	
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
	if(settingsController==nil) {
		settingsController=[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped withMap:mapview withDB:tiledb];
	}
	if(searchPlacesView==nil) {
		searchPlacesView=[[SearchPlacesView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) andController:self.navigationController andMap:mapview];
		searchPlacesView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	}
	NSLog(@"View height:  %f",self.view.frame.size.height);
//[self.view addSubview:debug];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:YES];
	
	[[NSUserDefaults standardUserDefaults] setFloat:[mapview getCurrentPos].x forKey:kSettingsLastPosX];
	[[NSUserDefaults standardUserDefaults] setFloat:[mapview getCurrentPos].y forKey:kSettingsLastPosY];

}
-(void)viewWillAppear:(BOOL)animated {
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense) {
		NSArray *btn=[NSArray arrayWithObjects:btnEnableGPS,space1,btnSearch,space2,btnSettings,nil];
		[toolbar setItems:btn animated:YES];	
		if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled) {
			btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
		} else{
			[mapview setHasGPSPos:NO];
			btnEnableGPS.title=NSLocalizedString(@"Enable GPS",@"Enable GPS Button");
		}
	}else {
		NSArray *btn=[NSArray arrayWithObjects:btnSearch,space2,btnSettings,nil];
		[toolbar setItems:btn animated:YES];	
		[mapview setHasGPSPos:NO];
		[mapview setNeedsDisplay];
	}	
	
	if(![[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsConditionsUse] isEqualToString:vSettingsConditionsUse]) {
		[[NSUserDefaults standardUserDefaults] setObject:vSettingsConditionsUse forKey:kSettingsConditionsUse];
		
	if(licenseView==nil) {
		licenseView=[[LicenseViewController alloc] init];
	}
	[self presentModalViewController:licenseView animated:YES];
	}
	PositionObj *p=[PositionObj positionWithX:[[NSUserDefaults standardUserDefaults] floatForKey:kSettingsLastPosX] y:[[NSUserDefaults standardUserDefaults] floatForKey:kSettingsLastPosY]];
	[mapview updateCurrentPos:p];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewDidAppear:(BOOL)animated {
	//CGRect viewRect2=[[UIScreen mainScreen] applicationFrame];
	//viewRect2.origin.y=0;
	//[UIView beginAnimations:nil context:nil];	
	//self.navigationController.navigationBarHidden=YES;
	//[UIView commitAnimations];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[mapview setNeedsDisplay];
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
	//[self actionSheet:nil willDismissWithButtonIndex:0];
	[super viewDidAppear:animated];
}
-(void) endRotation:(NSString*)animationID finished:(BOOL)finished context:(NSString*)context {
	[mapview setNeedsDisplay];
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//[self.view setNeedsLayout];
	//self.view.frame=[[UIScreen mainScreen] applicationFrame];
	//NSLog(@"Frame org (%f,%f) size (%f,%f)",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[mapview setNeedsDisplay];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
-(void)gpsEnableBtnPressed:(id)sender {
	//[self settingsBtnPressed:self];
	//return;
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled)
		[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] DisableGPS];
		else
			[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] EnableGPS];
	
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled) {
		btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
	} else{
		[mapview setHasGPSPos:NO];
		[mapview setNeedsDisplay];
		btnEnableGPS.title=NSLocalizedString(@"Enable GPS",@"Enable GPS Button");
	}
}
-(void)settingsBtnPressed:(id)sender {
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	[self.navigationController pushViewController:settingsController animated:YES];
}
-(void)searchBtnPressed:(id)sender {
	//Let the user choose between directions and place search
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
			searchPlacesView.alpha=0;
			[self.view addSubview:searchPlacesView];
			[UIView beginAnimations:nil context:nil];
			searchPlacesView.alpha=1;
			[UIView commitAnimations];
		}break;
		case 1: {
			
		}break;
	}
}
- (void)gpsChanged:(ChangedState*)msg {
	
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
			}

			break;
		case POS: {
			PositionObj *p=[[PositionObj alloc] init];
			p.x=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.latitude;
			p.y=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.longitude;
			[mapview updateCurrentPos:p];
			[mapview setHasGPSPos:YES];

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
				btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
			} else{
				[mapview setHasGPSPos:NO];
				btnEnableGPS.title=NSLocalizedString(@"Enable GPS",@"Enable GPS Button");
			}
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


- (void)dealloc {
	[super dealloc];
}

@end
