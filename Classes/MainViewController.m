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
@synthesize currentSearchType;
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
	CGRect viewRect=[[UIScreen mainScreen] applicationFrame];
	viewRect.size.height=viewRect.size.height-44.0f;
	
	self.view=[[UIView alloc] initWithFrame:viewRect];
	
	//self.navigationController.navigationBarHidden=YES;
	self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
	self.view.autoresizesSubviews=YES;
	
	
	//Inside the view:
	
	//self.view.backgroundColor=[UIColor blueColor];
	mapview=[[MapView alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,viewRect.size.height-44.0f) withDB:tiledb];
	mapview.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:mapview];
	zoomview=[[ZoomView alloc] initWithFrame:CGRectMake(10,10,38,83) withDelegate:mapview];
	[self.view addSubview:zoomview];
	speedview=[[SpeedView alloc] initWithFrame:CGRectMake(2.0f,viewRect.size.height-95.0f-2.0f-44.0f,92.0f,100.0f)];
	[speedview setSpeed:0];
	
	//[self.view addSubview:speedview];
	speedview.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
	toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0,viewRect.size.height-44.0f,viewRect.size.width,44.0f)];
	[self.view addSubview:toolbar];
	[self.view addSubview:speedview];
	btnEnableGPS=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Enable GPS",@"Enable GPS Button") style:UIBarButtonItemStyleBordered target:self action:@selector(gpsEnableBtnPressed:)];
	toolbar.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	//btnSettings=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings",@"Settings Button") style:UIBarButtonItemStyleBordered target:self action:@selector(settingsBtnPressed:)];
	btnSettings=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settingsIcon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(settingsBtnPressed:)];
	btnSearch=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBtnPressed:)];
	btnSearch.style=UIBarButtonItemStyleBordered;
	space1=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	space2=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	NSArray *btn=[NSArray arrayWithObjects:btnSearch,space2,btnSettings,nil];
	[toolbar setItems:btn animated:YES];	
	//92x100
	settingsController=[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	searchPlacesView=[[SearchPlacesView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,[[UIScreen mainScreen] applicationFrame].size.height) andController:self andMap:mapview];
	searchPlacesView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	searchPlacesView.autoresizesSubviews=YES;
	
	drivingSearchView=[[DrivingDirectionsSearchView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,[[UIScreen mainScreen] applicationFrame].size.height) andController:self andMap:mapview];
	drivingSearchView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	drivingSearchView.autoresizesSubviews=YES;
	
	signalView=[[GPSSignalView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-52,5,47,40)];
	signalView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self.view addSubview:signalView];
	[signalView setQuality:-1];
	
	speedview.hidden=YES;
	signalView.hidden=YES;
	cancelSearch=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelDrivingSearch:)];
	savedDirections=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Bookmarks",@"Saved direction bookmarks") style:UIBarButtonItemStyleBordered target:self action:@selector(showBooksmarksView:)];
	navView=[[NavigationInstructionView alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,50)];
	navView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	navView.delegate=APPDELEGATE.directions;
	wrongWay=[[WrongWayView alloc] initWithFrame:CGRectMake(viewRect.size.width-140,70,-1,-1) withDelegate:self];
	navView.autoresizesSubviews=YES;
	wrongWay.autoresizingMask=UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
	APPDELEGATE.directions.map=mapview;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speedChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
	
	PositionObj *p=[PositionObj positionWithX:[[NSUserDefaults standardUserDefaults] doubleForKey:kSettingsLastPosX] y:[[NSUserDefaults standardUserDefaults] doubleForKey:kSettingsLastPosY]];
	if(p.x==0.0f && p.y==0.0f) {
		p.x=46.5833333;
		p.y=6.55;
	}
	
	
	int zoom=[[NSUserDefaults standardUserDefaults] doubleForKey:kSettingsLastZoom];
	if(zoom>=0 && zoom<18)
		[mapview setZoom:zoom];
	
	mapview.pos=p;
	mapview.mapRotationEnabled=![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapRotation];
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense) {
		int gpsState=[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsGPSState];
		
		if(gpsState==1) {
			btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
			btnEnableGPS.style=UIBarButtonItemStyleBordered;	
			[mapview setGPSTracking:NO];
			[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] EnableGPS];
		}else if(gpsState==2) {
			btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
			btnEnableGPS.style=UIBarButtonItemStyleDone;	
			[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] EnableGPS];
			[mapview setGPSTracking:YES];
		}
	}
	tmrNightMode=[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerNightMode) userInfo:nil repeats:YES];
	[tmrNightMode retain];
	[self speedChanged:nil];
	[self viewWillAppear:YES];
}
-(void)timerNightMode {
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled]) {
		NSCalendar *currentCalendar = [NSCalendar currentCalendar];
		NSDate *now=[NSDate date];
		NSDateComponents *comp=[currentCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];
		//int actMinute=[comp minute];
		int actHour=[comp hour];
		if(actHour>=20 || actHour<7) {
			if(mapview.nightMode!=YES) {
				[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];	
				[navView setNightMode:YES];
				mapview.nightMode=YES;
				toolbar.barStyle=UIBarStyleBlackOpaque;
				[mapview refreshMap];
			}
		} else {
			if(mapview.nightMode==YES) {
				[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
				mapview.nightMode=NO;
				[navView setNightMode:NO];
				toolbar.barStyle=UIBarStyleDefault;
				[mapview refreshMap];
			}
		}
	}
}
-(void)speedChanged:(NSNotification *)notif {
	NSLog(@"Settings changed...");
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowSpeed] && APPDELEGATE.gpsmanager.currentGPS.isEnabled) {
		speedview.hidden=NO;
	} else {
		speedview.hidden=YES;
		
	}
	if(![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled] || ![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled]) {
		if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled]) {
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];	
			[navView setNightMode:YES];
			mapview.nightMode=YES;
			toolbar.barStyle=UIBarStyleBlackOpaque;
			[mapview refreshMap];
		} else {
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
			mapview.nightMode=NO;
			[navView setNightMode:NO];
			toolbar.barStyle=UIBarStyleDefault;
			[mapview refreshMap];
		}
	} else {
		[self timerNightMode];	
	}
	
}
-(void)hideWrongWay {
	if(wrongWay.superview==nil) return;
	[wrongWay stopAnimate];
	
	[wrongWay removeFromSuperview];
	
}
-(void)showWrongWay {
	if(wrongWay.superview!=nil) return;
	[wrongWay startAnimate];
	[self.view addSubview:wrongWay];
}
-(void)showBooksmarksView:(id)sender {
	if(dirBookmarks==nil) {
		dirBookmarks=[[DirectionsBookmarksViewController alloc] initWithStyle:UITableViewStylePlain delegate:drivingSearchView];
		
	}
	
	UINavigationController *navigationController = [[UINavigationController 
													 alloc] initWithRootViewController:dirBookmarks]; 
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
}
-(void)hideGPSStatus {
	[UIView beginAnimations:nil context:nil];
	//[speedview removeFromSuperview];
	speedview.hidden=YES;
	signalView.hidden=YES;
	[UIView commitAnimations];
}
-(void)showGPSStatus {
	[UIView beginAnimations:nil context:nil];
	//[self.view addSubview:speedview];
	signalView.hidden=NO;
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowSpeed])
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
	[[NSUserDefaults standardUserDefaults] setDouble:[mapview getCurrentPos].x forKey:kSettingsLastPosX];
	[[NSUserDefaults standardUserDefaults] setDouble:[mapview getCurrentPos].y forKey:kSettingsLastPosY];
	[[NSUserDefaults standardUserDefaults] setInteger:[mapview zoom] forKey:kSettingsLastZoom];
}
-(void)viewWillAppear:(BOOL)animated {
	if(!directionSearch)
		self.title=@"xGPS";
	else
		self.title=NSLocalizedString(@"Directions",@"");
	
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense) {
		NSArray *btn=[NSArray arrayWithObjects:btnEnableGPS,space1,btnSearch,space2,btnSettings,nil];
		[toolbar setItems:btn animated:YES];	
		if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled) {
			
			
			[mapview setHasGPSPos:YES];
			
			if([btnEnableGPS.title isEqualToString:NSLocalizedString(@"Enable GPS",@"Enable GPS Button")])
				[mapview setGPSTracking:YES];
			
			btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
			if([mapview hasGPSTracking]) {
				btnEnableGPS.style=UIBarButtonItemStyleDone;
			}else {
				btnEnableGPS.style=UIBarButtonItemStyleBordered;	
				
			}
			[mapview refreshMap];
			[self showGPSStatus];
		} else{
			[mapview setHasGPSPos:NO];
			[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kSettingsGPSState];
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
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewDidAppear:(BOOL)animated {
	if(!directionSearch)
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	[mapview refreshMap];
	
	[super viewDidAppear:animated];
}
-(void) endRotation:(NSString*)animationID finished:(BOOL)finished context:(NSString*)context {
	[self.navigationController pushViewController:settingsController animated:YES];
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if(!directionSearch)
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	
	[UIView beginAnimations:nil context:nil];
	[navView sizeToFit];
	if(currentSearchType==2) {
		mapview.frame=CGRectMake(0,navView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-navView.frame.size.height);
	}
	if(currentSearchType!=1) {
		searchPlacesView.frame=CGRectMake(0,0,self.view.frame.size.width,[[UIScreen mainScreen] applicationFrame].size.height);
	}
	if(currentSearchType!=2) {
		drivingSearchView.frame=CGRectMake(0,0,self.view.frame.size.width,[[UIScreen mainScreen] applicationFrame].size.height);
		navView.frame=CGRectMake(0,0,self.view.frame.size.width,50);
		wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70,wrongWay.frame.size.width,wrongWay.frame.size.height);
	} else {
		wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70+navView.frame.size.height,wrongWay.frame.size.width,wrongWay.frame.size.height);
	}
	
	[mapview refreshMap];
	[UIView commitAnimations];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
-(void)gpsEnableBtnPressed:(id)sender {
	BOOL wasEnabled=NO;
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled && btnEnableGPS.style!=UIBarButtonItemStyleDone) {
		[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] DisableGPS];
		btnEnableGPS.style=UIBarButtonItemStyleBordered;
		[mapview setGPSTracking:NO];
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kSettingsGPSState];
		wasEnabled=YES;
	}
	else if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled && btnEnableGPS.style==UIBarButtonItemStyleDone){
		btnEnableGPS.style=UIBarButtonItemStyleBordered;
		[mapview setGPSTracking:NO];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kSettingsGPSState];
	} else {
		[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] EnableGPS];
		btnEnableGPS.style=UIBarButtonItemStyleDone;
		[mapview setGPSTracking:YES];
		[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:kSettingsGPSState];
	}
	if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled) {
		btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
		[self showGPSStatus];
		
		[mapview setHasGPSPos:YES];
		if(wasEnabled) {
			btnEnableGPS.style=UIBarButtonItemStyleDone;
			[mapview setGPSTracking:YES];
			
		}
		[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:kSettingsGPSState];
		
		
	} else{
		[mapview setHasGPSPos:NO];
		[mapview refreshMap];
		[self hideGPSStatus];
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kSettingsGPSState];
		[signalView setQuality:-1];
		btnEnableGPS.style=UIBarButtonItemStyleBordered;
		[self hideWrongWay];
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
	/*if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline]) {
	 UIAlertView *msg=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"You cannot do a search request while you are in the offline mode. You can switch off the offline mode by tapping the Settings button.",@"Error search offline") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
	 [msg show];
	 return;
	 }*/
	
	UIActionSheet *action=nil;
	
	if(currentSearchType==0)
		action=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Search for:",@"Search actionsheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Places / Cities",@"Search for places"),NSLocalizedString(@"Driving directions",@"Driving directions"),nil];
	else if(currentSearchType==1)
		action=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Search for:",@"Search actionsheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Places / Cities",@"Search for places"),NSLocalizedString(@"Driving directions",@"Driving directions"),NSLocalizedString(@"Clear Search results",@""),nil];
	else
		action=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Search for:",@"Search actionsheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Places / Cities",@"Search for places"),NSLocalizedString(@"Driving directions",@"Driving directions"),NSLocalizedString(@"Clear Driving directions",@""),nil];
	[action showFromToolbar:toolbar];
}
-(void)cancelSearchPressed:(id)sender {
	[UIView beginAnimations:nil context:nil];	
	[searchPlacesView removeFromSuperview];
	[UIView commitAnimations];
}
-(void)cancelDrivingSearch:(id)sender {
	[UIView beginAnimations:nil context:nil];	
	[drivingSearchView removeFromSuperview];
	[mapview refreshMap];
	self.navigationItem.title=@"xGPS";
	self.navigationItem.rightBarButtonItem=nil;
	self.navigationItem.leftBarButtonItem=nil;
	[UIView commitAnimations];
	directionSearch=NO;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
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
			directionSearch=YES;
			
			//UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"This feature will be implemented in a future version.",@"Not yet implemented message.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
			//[alert show];
			//return;
			self.navigationItem.leftBarButtonItem.enabled=YES;
			self.navigationItem.rightBarButtonItem.enabled=YES;
			[UIView beginAnimations:nil context:nil];
			[self.view addSubview:drivingSearchView];
			self.navigationController.navigationBarHidden=NO;
			self.navigationItem.title=NSLocalizedString(@"Directions",@"");
			self.navigationItem.rightBarButtonItem=cancelSearch;
			self.navigationItem.leftBarButtonItem=savedDirections;
			[mapview refreshMap];
			[UIView commitAnimations];
			
		}break;
		case 2: {
			if(currentSearchType==1) {
				[mapview setPosSearch:nil];
			} else if(currentSearchType==2) {
				[self clearDirections];
			}
			currentSearchType=0;
		}
	}
}
-(void)clearDirections {
	[UIView beginAnimations:nil context:nil];	
	[navView removeFromSuperview];
	mapview.frame=CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-44.0f);
	zoomview.frame=CGRectMake(10,10,38,83);
	wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70,wrongWay.frame.size.width,wrongWay.frame.size.height);
	signalView.frame=CGRectMake(self.view.frame.size.width-52,5,47,40);
	[UIView commitAnimations];
	[APPDELEGATE.directions clearResult];
	currentSearchType=0;
	[wrongWay stopAnimate];
	[wrongWay removeFromSuperview];
}
-(void)nextDirectionChanged:(Instruction*)instr {
	if(instr.dist<500)
		[navView setText:[NSString stringWithFormat:@"%@\nIn %.1f m",instr.name,instr.dist]];
	else
		[navView setText:[NSString stringWithFormat:@"%@\nIn %.1f km",instr.name,instr.dist/1000.0]];
	
	[UIView beginAnimations:nil context:nil];	
	[navView sizeToFit];
	mapview.frame=CGRectMake(0,navView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-navView.frame.size.height-44.0f);
	zoomview.frame=CGRectMake(10,10+navView.frame.size.height,38,83);
	wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70+navView.frame.size.height,wrongWay.frame.size.width,wrongWay.frame.size.height);
	signalView.frame=CGRectMake(self.view.frame.size.width-52,5+navView.frame.size.height,47,40);
	[UIView commitAnimations];
}
-(void)nextDirectionDistanceChanged:(double)dist {
	
}
-(void)directionsGot:(NSString*)from to:(NSString*)to error:(NSError*)err {
	self.navigationItem.leftBarButtonItem.enabled=YES;
	self.navigationItem.rightBarButtonItem.enabled=YES;
	if(err==nil) {
		
		//Search the first instruction
		if([APPDELEGATE.directions.instructions count]>0) {
			
			
			[UIView beginAnimations:nil context:nil];	
			[drivingSearchView removeFromSuperview];
			
			self.navigationItem.title=@"xGPS";
			self.navigationItem.rightBarButtonItem=nil;
			self.navigationItem.leftBarButtonItem=nil;
			[self.view addSubview:navView];
			mapview.frame=CGRectMake(0,navView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-navView.frame.size.height-44.0f);
			zoomview.frame=CGRectMake(10,10+navView.frame.size.height,38,83);
			wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70+navView.frame.size.height,wrongWay.frame.size.width,wrongWay.frame.size.height);
			signalView.frame=CGRectMake(self.view.frame.size.width-52,5+navView.frame.size.height,47,40);
			[UIView commitAnimations];
			directionSearch=NO;
			[mapview computeCachedRoad];
			currentSearchType=2;
			[self.navigationController setNavigationBarHidden:YES animated:YES];
			
		} else {
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"No driving direction can be computed using your query.",@"No driving dir. found error message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
			[alert show];
			[drivingSearchView setEditingKeyBoard];
		}
	}
	else {
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:[NSString stringWithFormat:NSLocalizedString(@"Unable to retrieve the driving directions from the server: %@",@"Network error message"),[err localizedDescription]] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[alert show];
		[drivingSearchView setEditingKeyBoard];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
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
				[signalView setQuality:-1];
				[self hideGPSStatus];
			}
			[settingsController reload];
			break;
		case POS: {
			if(gpsPos==nil) return;
			
			double speedms=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.speed;
			speedms*=3.6f;
			if(speedms>3)
				[speedview setSpeed:speedms];
			else
				[speedview setSpeed:0];
			
			gpsPos.x=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.latitude;
			gpsPos.y=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.longitude;
			[mapview updateCurrentPos:gpsPos];
			[mapview setHasGPSPos:YES];
			
			[APPDELEGATE.gpxlogger logGPXPoint:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.latitude lon:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.longitude alt:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.altitude speed:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.speed fix:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.mode sat:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].satellites_used];
			APPDELEGATE.directions.pos=gpsPos;
			break;
		}case SPEED: {
			double speedms=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.speed;
			speedms*=3.6f;
			if(speedms>3)
				[speedview setSpeed:speedms];
			else
				[speedview setSpeed:0];
		}break;
		case STATE_CHANGE:
			if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled) {
				[self showGPSStatus];
				btnEnableGPS.title=NSLocalizedString(@"Disable GPS",@"Disable GPS Button");
				[mapview setGPSTracking:YES];
				btnEnableGPS.style=UIBarButtonItemStyleDone;
			} else{
				[mapview setHasGPSPos:NO];
				[self hideGPSStatus];
				btnEnableGPS.style=UIBarButtonItemStyleBordered;
				btnEnableGPS.title=NSLocalizedString(@"Enable GPS",@"Enable GPS Button");
				[signalView setQuality:-1];
				[mapview setGPSTracking:NO];
			}
			break;
		case SIGNAL_QUALITY:
			[signalView setQuality:[[xGPSAppDelegate gpsmanager] GetCurrentGPS].signalQuality];
			[APPDELEGATE.gpxlogger gpsSignalChanged:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.mode>=2];
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
