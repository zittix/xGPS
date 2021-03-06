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
#import "RoutesManagerViewController.h"
#import "iPhone3GController.h"
#import "ProgressViewController.h"

@interface UIApplication(Improved)
-(void)addStatusBarImageNamed:(NSString*)name removeOnExit:(BOOL)v;
-(void)addStatusBarImageNamed:(NSString*)name removeOnAbnormalExit:(BOOL)v;
-(void)removeStatusBarImageNamed:(NSString*)name;
@end



@implementation MainViewController

@synthesize mapview;
@synthesize currentSearchType;
@synthesize tiledb;
-(id)init {
	if((self=[super init])) {
		//NSLog(@"MainView controller init...");
		tiledb=[xGPSAppDelegate tiledb];
		currentStatusbarIconState=-1;
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
	mapview=[[MapView alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,viewRect.size.height) withDB:tiledb];
	mapview.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	viewSearch=[[ViewSearch alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,viewRect.size.height) delegate:self];
	viewSearch.frame=CGRectMake(viewRect.size.width/2.0,viewRect.size.height/2.0,1,1);
	[self.view addSubview:mapview];
	zoomview=[[ZoomView alloc] initWithFrame:CGRectMake(10,10,38,83) withDelegate:mapview];
	[self.view addSubview:zoomview];
	speedview=[[SpeedView alloc] initWithFrame:CGRectMake(2.0f,viewRect.size.height-95.0f-2.0f-44.0f,92.0f,100.0f) delegate:self];
	[speedview setSpeed:0];
	
	//[self.view addSubview:speedview];
	speedview.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
	
	
	[self.view addSubview:speedview];
	
	btnSettings=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
	btnSearch=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[btnSettings setImage:[UIImage imageNamed:@"settings_button.png"] forState:UIControlStateNormal];
	[btnSearch setImage:[UIImage imageNamed:@"search_button.png"] forState:UIControlStateNormal];
	
	btnSettings.frame=CGRectMake(20.0,self.view.frame.size.height-45.0f,40.0f,40.0f);
	btnSettings.autoresizingMask=UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
	[btnSettings addTarget:self action:@selector(settingsBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnSettings];
	
	btnSearch.frame=CGRectMake((self.view.frame.size.width-40)/2.0,self.view.frame.size.height-45.0f,40.0f,40.0f);
	btnSearch.autoresizingMask=UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
	[btnSearch addTarget:self action:@selector(searchBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnSearch];
	
	
	//92x100
	settingsController=[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	searchPlacesView=[[SearchPlacesView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,[[UIScreen mainScreen] applicationFrame].size.height) andController:self.navigationController delegate:self];
	searchPlacesView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	searchPlacesView.autoresizesSubviews=YES;
	
	drivingSearchView=[[DrivingDirectionsSearchView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,[[UIScreen mainScreen] applicationFrame].size.height) andController:self andMap:mapview];
	drivingSearchView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	drivingSearchView.autoresizesSubviews=YES;
	
	speedview.hidden=YES;
	
	cancelSearch=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelDrivingSearch:)];
	routesManager=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Manager",@"") style:UIBarButtonItemStyleBordered target:self action:@selector(showManager:)];
	navView=[[NavigationInstructionView alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,50)];
	navView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	navView.delegate=APPDELEGATE.directions;
	wrongWay=[[WrongWayView alloc] initWithFrame:CGRectMake(viewRect.size.width-140,70,-1,-1) withDelegate:self];
	navView.autoresizesSubviews=YES;
	
	wrongWay.autoresizingMask=UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
	
	
	remainingView=[[RemainingDistanceTimeView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100,self.view.frame.size.height-60,100,70)];
	remainingView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	
	remainingView.autoresizesSubviews=YES;
	APPDELEGATE.directions.map=mapview;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speedChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
	[self setStatusIconVisible:YES state:0];
	PositionObj *p=[PositionObj positionWithX:[[NSUserDefaults standardUserDefaults] doubleForKey:kSettingsLastPosX] y:[[NSUserDefaults standardUserDefaults] doubleForKey:kSettingsLastPosY]];
	if(p.x==0.0f && p.y==0.0f) {
		p.x=46.5833333;
		p.y=6.55;
	}
	
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsMapType]==0)
		mapview.maxZoom=17;
	else
		mapview.maxZoom=15;
	
	int zoom=[[NSUserDefaults standardUserDefaults] doubleForKey:kSettingsLastZoom];
	if(zoom>=17-mapview.maxZoom && zoom<=17)
		[mapview setZoom:zoom];
	else
		[mapview setZoom:17-mapview.maxZoom];
	
	mapview.pos=p;
	mapview.mapRotationEnabled=![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapRotation];
	[self setGPSMode:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsGPSState]];
	tmrNightMode=[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerNightMode) userInfo:nil repeats:YES];
	[tmrNightMode retain];
	[self speedChanged:nil];
	[self viewWillAppear:YES];
	[self setGPSQuality:-1];
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsLastUsedBookmark]>=0) {
		NSMutableArray *road=[APPDELEGATE.dirbookmarks copyBookmarkRoadPoints:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsLastUsedBookmark]];
		NSMutableArray *instr=[APPDELEGATE.dirbookmarks copyBookmarkInstructions:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsLastUsedBookmark]];
		[APPDELEGATE.directions setRoad:road instructions:instr];
		
		NSString *to=nil,*from=nil;
		NSArray *via=nil;
		
		if([APPDELEGATE.dirbookmarks getBookmarkInfo:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsLastUsedBookmark] from:&from to:&to via:&via]) {
			NSLog(@"Restoring to: %@, from: %@, via:%@",to,from,via);
			[APPDELEGATE.directions setTo:to];
			[APPDELEGATE.directions setFrom:from];
			[APPDELEGATE.directions setVia:via];
			[to release];
			[from release];
			[via release];
		}
		[road release];
		[instr release];
	}
	/*
	 SoundEvent *s=[[SoundEvent alloc] initWithText:@"Hi man how are you doing today?"];
	 [APPDELEGATE.soundcontroller addSound:s];	
	 [s release];*/
}
-(void)hideLicense {
	[self dismissModalViewControllerAnimated:YES];
}
-(void)setGPSQuality:(int)q {
	
	if(q<33) {
		[self setStatusIconVisible:YES state:0];
	} else if(q<66) {
		[self setStatusIconVisible:YES state:1];
	} else {
		[self setStatusIconVisible:YES state:2];
	}
}
-(void)showManager:(id)sender {
	UIViewController *manager=[[RoutesManagerViewController alloc] initWithStyle:UITableViewStylePlain delegate:drivingSearchView];
	UINavigationController *navigationController = [[UINavigationController 
													 alloc] initWithRootViewController:manager]; 
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
	[manager release];
}

-(void)btnSearchPlacePressed {
	searchPlacesView.frame=CGRectMake(0,0,self.view.frame.size.width,[[UIScreen mainScreen] applicationFrame].size.height);
	[UIView beginAnimations:nil context:nil];
	[self.view addSubview:searchPlacesView];
	[UIView commitAnimations];
	[viewSearch hide];
}
-(void)btnSearchRoutePressed {
	directionSearch=YES;
	self.navigationItem.leftBarButtonItem.enabled=YES;
	self.navigationItem.rightBarButtonItem.enabled=YES;
	drivingSearchView.frame=CGRectMake(0,0,self.view.frame.size.width,[[UIScreen mainScreen] applicationFrame].size.height);
	[UIView beginAnimations:nil context:nil];
	[self.view addSubview:drivingSearchView];
	self.navigationController.navigationBarHidden=NO;
	self.navigationItem.title=NSLocalizedString(@"Directions",@"");
	self.navigationItem.rightBarButtonItem=cancelSearch;
	self.navigationItem.leftBarButtonItem=routesManager;
	[mapview refreshMap];
	[UIView commitAnimations];
	[viewSearch hide];
}
-(void)btnRoutesManagerPressed {
	[viewSearch hide];
	[self showManager:nil];
}
-(void)btnHomePressed {
	[viewSearch hide];
	
	NSString *homeAddress=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsHomeAddress];
	if(homeAddress==nil || homeAddress.length==0) {
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"You have to set your home address in Settings -> Driving directions -> Home Address, before using this feature.",@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[alert show];
	} else {
		
		NSString *currentPosition;
		GPSController *g=[[xGPSAppDelegate gpsmanager] GetCurrentGPS];
		if(g.gps_data.fix.mode>1) {
			float lat=g.gps_data.fix.latitude;
			float lon=g.gps_data.fix.longitude;
			
			currentPosition=[NSString stringWithFormat:@"%f,%f",lat,lon];
		} else {
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"Unable to get the GPS position. The GPS is not currently giving any position information.",@"GPS Dir Pos error message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
			[alert show];	
			return;
		}
		
		
		
		if(![APPDELEGATE.directions drive:currentPosition to:homeAddress via:nil delegate:nil]) {
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:[NSString stringWithFormat:NSLocalizedString(@"Unable to retrieve the required information from the server: %@",@"Network error message"),NSLocalizedString(@"Unknown error",@"Unknown error")] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
			[alert show];
			[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
			return;
		}
		
		ProgressViewController *pController=[[ProgressViewController alloc] init];
		
		[pController.progress hideCancelButton];
		pController.progress.ltext.text=NSLocalizedString(@"Computing your route...",@"");
		[pController.progress setProgress:0.2];
		APPDELEGATE.directions.routingType=ROUTING_NORMAL;
		
		[self presentModalViewController:pController animated:NO];
		
	}
}
-(void)btnClearPressed {
	if(currentSearchType==1) {
		[mapview setPosSearch:nil];
	} else if(currentSearchType==2) {
		[self clearDirections];
	}
	currentSearchType=0;
	[viewSearch hide];
}
-(void) searchPlaceWillHide {
	
}
-(void)showGPSDetails {
	if(gpsdetails==nil) {
		gpsdetails=[[GPSDetailsViewController alloc] init];
		
	}
	[self presentModalViewController:gpsdetails animated:YES];
}
-(void)timerNightMode {
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled] && [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled]) {
		NSCalendar *currentCalendar = [NSCalendar currentCalendar];
		NSDate *now=[NSDate date];
		NSDateComponents *comp=[currentCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];
		int actMinute=[comp minute];
		int actHour=[comp hour];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateFormat:@"HH:mm"];
		
		
		NSString *start=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsTimerNightStart];
		if(start==nil) start=@"20:00";
		NSString *stop=[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsTimerNightStop];
		if(stop==nil) stop=@"7:00";
		
		NSDate *startDate=[dateFormatter dateFromString:start];
		NSDate *stopDate=[dateFormatter dateFromString:stop];
		
		//if([stopDate compare:startDate]==NSOrderedAscending)
		//	stopDate=[stopDate addTimeInterval:24*60*60];
		
		//NSDate *curDate=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d:%d",actHour,actMinute]];
		//NSComparisonResult resStart=[curDate compare:startDate];
		//NSComparisonResult resStop=[curDate compare:stopDate];
		
		
		comp=[currentCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:startDate];
		int startMinute=[comp minute];
		int startHour=[comp hour];
		
		comp=[currentCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:stopDate];
		int stopMinute=[comp minute];
		int stopHour=[comp hour];
		
		
		[dateFormatter release];
		
		BOOL nightModeDateNotAfter=actHour>startHour || actHour<stopHour || (actHour==startHour && actMinute>=startMinute) || (actHour==stopHour && actMinute<stopMinute);
		BOOL nightModeDateAfter=(actHour>startHour && actHour<stopHour) || (actHour==startHour && actMinute>=startMinute && actMinute<stopMinute) || (actHour==stopHour && actMinute<stopMinute && actMinute>=startMinute);
		
		
		if((nightModeDateNotAfter && (startHour>stopHour || (startHour==stopHour && startMinute>stopMinute))) || (nightModeDateAfter && (startHour<stopHour || (startHour==stopHour && startMinute<stopMinute)))) {
			if(mapview.nightMode!=YES) {
				[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];	
				[navView setNightMode:YES];
				[remainingView setNightMode:YES];
				mapview.nightMode=YES;
				[mapview refreshMap];
			}
		} else {
			if(mapview.nightMode==YES) {
				[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
				mapview.nightMode=NO;
				[navView setNightMode:NO];
				[remainingView setNightMode:NO];
				[mapview refreshMap];
			}
		}
	}
}
- (void)setStatusIconVisible:(BOOL)visible state:(int)state {
	if (visible && currentStatusbarIconState!=state) {
		
		if(currentStatusbarIconState>=0) {
			[[UIApplication sharedApplication] removeStatusBarImageNamed:
			 
			 [NSString stringWithFormat:@"xGPS_sat_%d", currentStatusbarIconState]];
		}
		
		
		NSString *name = [NSString
						  
						  stringWithFormat:@"xGPS_sat_%d", state];
		
		if ([[UIApplication sharedApplication]
			 
			 respondsToSelector:@selector(addStatusBarImageNamed:removeOnExit:)])
			
			[[UIApplication sharedApplication] addStatusBarImageNamed:name removeOnExit:YES];
		
		else
			
			[[UIApplication sharedApplication] addStatusBarImageNamed:name removeOnAbnormalExit:YES];
		
		currentStatusbarIconState=state;
		
	} else if(!visible) {
		if(currentStatusbarIconState==state) {
			[[UIApplication sharedApplication] removeStatusBarImageNamed:
			 
			 [NSString stringWithFormat:@"xGPS_sat_%d", state]];
			currentStatusbarIconState=-1;
		}
		
	}
	
}
-(void)speedChanged:(NSNotification *)notif {
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowSpeed] && APPDELEGATE.gpsmanager.currentGPS.isEnabled) {
		speedview.hidden=NO;
	} else {
		speedview.hidden=YES;
		
	}
	[self setGPSMode:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsGPSState]];
	
	if(![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsTimerNightEnabled]) {
		if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled]) {
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];	
			[navView setNightMode:YES];
			mapview.nightMode=YES;
			[remainingView setNightMode:YES];
			[mapview refreshMap];
		} else {
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
			mapview.nightMode=NO;
			[navView setNightMode:NO];
			[remainingView setNightMode:NO];
			[mapview refreshMap];
		}
	} else {
		[self timerNightMode];	
	}
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsMapType]==0)
		mapview.maxZoom=17;
	else
		mapview.maxZoom=15;
	
	if(APPDELEGATE.tiledb.type!=[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsMapType]) {
		APPDELEGATE.tiledb.type=[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsMapType];
		[mapview fulllRefreshMap];
	}
	
	
}
-(void)hideWrongWay {
	if(wrongWay.superview==nil) return;
	[wrongWay stopAnimate];
	
}
-(void)showWrongWay {
	if(wrongWay.superview!=nil) return;
	[wrongWay startAnimate];
	[self.view addSubview:wrongWay];
}

-(void)hideGPSStatus {
	[UIView beginAnimations:nil context:nil];
	//[speedview removeFromSuperview];
	speedview.hidden=YES;
	[UIView commitAnimations];
}
-(void)showGPSStatus {
	[UIView beginAnimations:nil context:nil];
	//[self.view addSubview:speedview];
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsShowSpeed])
		speedview.hidden=NO;
	[UIView commitAnimations];
}
- (void)dealloc {
	[mapview release];
	[zoomview release];
	[viewSearch release];
	[speedview release];
	[remainingView release];
	[btnSettings release];
	[btnSearch release];
	[settingsController release];
	[searchPlacesView release];
	[gpsPos release];
	[super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	hidden=YES;
	[super viewWillDisappear:YES];
	self.title=NSLocalizedString(@"Map","Map");
	[[NSUserDefaults standardUserDefaults] setDouble:[mapview getCurrentPos].x forKey:kSettingsLastPosX];
	[[NSUserDefaults standardUserDefaults] setDouble:[mapview getCurrentPos].y forKey:kSettingsLastPosY];
	[[NSUserDefaults standardUserDefaults] setInteger:[mapview zoom] forKey:kSettingsLastZoom];
}
-(void)viewWillAppear:(BOOL)animated {
	hidden=NO;
	if(!directionSearch)
		self.title=@"xGPS";
	else
		self.title=NSLocalizedString(@"Directions",@"");
	
	[self setGPSMode:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsGPSState]];
	
	if(![[[NSUserDefaults standardUserDefaults] stringForKey:kSettingsConditionsUse] isEqualToString:vSettingsConditionsUse]) {
		[[NSUserDefaults standardUserDefaults] setObject:vSettingsConditionsUse forKey:kSettingsConditionsUse];
		
		if(licenseView==nil) {
			licenseView=[[LicenseViewController alloc] init];
			[licenseView setDelegate:self];
		}
		[self presentModalViewController:licenseView animated:YES];
	}
	
	if(mapview.zoom<17-mapview.maxZoom) {
		mapview.zoom=mapview.maxZoom;
		[mapview fulllRefreshMap];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[viewSearch changeOrientation:toInterfaceOrientation];
}
- (void)viewDidAppear:(BOOL)animated {
	if(!directionSearch)
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	[mapview refreshMap];
	navView.frame=CGRectMake(0,0,self.view.frame.size.width,50);
	remainingView.frame=CGRectMake(self.view.frame.size.width-100,self.view.frame.size.height-60,100,70);
	if(currentSearchType==2) {
		[UIView beginAnimations:nil context:nil];	
		[navView sizeToFit];
		mapview.frame=CGRectMake(0,navView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-navView.frame.size.height);
		zoomview.frame=CGRectMake(10,10+navView.frame.size.height,38,83);
		wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70+navView.frame.size.height,wrongWay.frame.size.width,wrongWay.frame.size.height);
		[UIView commitAnimations];
	}
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
-(void)setGPSMode:(int)mode {
	//NSLog(@"Setting mode: %d",mode);
	if(mode==0) {
		[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] DisableGPS];
		[mapview setGPSTracking:NO];
		[mapview setHasGPSPos:NO];
		[mapview refreshMap];
		[self hideGPSStatus];
		[self setGPSQuality:-1];
		[self hideWrongWay];
	}
	else if(mode==1 && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense){
		[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] EnableGPS];
		[self showGPSStatus];
		//[mapview setHasGPSPos:NO];
		[mapview setGPSTracking:NO];
	} else if(mode==2 && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].validLicense){
		[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] EnableGPS];
		[self showGPSStatus];
		//[mapview setHasGPSPos:NO];
		[mapview setGPSTracking:YES];
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
	/*
	 UIActionSheet *action=nil;
	 
	 if(currentSearchType==0)
	 action=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Places / Cities",@"Search for places"),NSLocalizedString(@"Driving directions",@"Driving directions"),NSLocalizedString(@"Routes Manager",@""),nil];
	 else if(currentSearchType==1)
	 action=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Places / Cities",@"Search for places"),NSLocalizedString(@"Driving directions",@"Driving directions"),NSLocalizedString(@"Routes Manager",@""),NSLocalizedString(@"Clear Search results",@""),nil];
	 else
	 action=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Places / Cities",@"Search for places"),NSLocalizedString(@"Driving directions",@"Driving directions"),NSLocalizedString(@"Routes Manager",@""),NSLocalizedString(@"Clear Driving directions",@""),nil];
	 [action showInView:self.view];*/
	[viewSearch showInView:self.view];
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
	if(!hidden)
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	
}
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	
}
-(void)clearDirections {
	[UIView beginAnimations:nil context:nil];	
	[navView removeFromSuperview];
	[remainingView removeFromSuperview];
	mapview.frame=CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
	zoomview.frame=CGRectMake(10,10,38,83);
	wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70,wrongWay.frame.size.width,wrongWay.frame.size.height);
	[UIView commitAnimations];
	[APPDELEGATE.directions clearResult];
	currentSearchType=0;
	[wrongWay stopAnimate];
}
-(void)nextDirectionChanged:(Instruction*)instr {
	[navView setText:instr.name];
	[UIView beginAnimations:nil context:nil];	
	[navView sizeToFit];
	mapview.frame=CGRectMake(0,navView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-navView.frame.size.height);
	zoomview.frame=CGRectMake(10,10+navView.frame.size.height,38,83);
	wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70+navView.frame.size.height,wrongWay.frame.size.width,wrongWay.frame.size.height);
	[UIView commitAnimations];
	
}
-(void)nextDirectionDistanceChanged:(double)dist total:(double)totalDist{
	[remainingView setDistance:dist];
	[remainingView setTotalDistance:totalDist];
}
-(void)gotResultForSearch:(GeoEncoderResult*)res {
	if(currentSearchType!=1) [self btnClearPressed];
	
	[mapview setPosSearch:res.pos];
	currentSearchType=1;
}
-(void)directionsGot:(NSString*)from to:(NSString*)to error:(NSString*)err {
	self.navigationItem.leftBarButtonItem.enabled=YES;
	self.navigationItem.rightBarButtonItem.enabled=YES;
	[self dismissModalViewControllerAnimated:YES];
	if(err==nil) {
		
		//Search the first instruction
		if([APPDELEGATE.directions.instructions count]>0) {
			if(currentSearchType!=2) [self btnClearPressed];
			
			[UIView beginAnimations:nil context:nil];	
			[drivingSearchView removeFromSuperview];
			
			self.navigationItem.title=@"xGPS";
			self.navigationItem.rightBarButtonItem=nil;
			self.navigationItem.leftBarButtonItem=nil;
			[self.view addSubview:navView];
			[self.view addSubview:remainingView];
			mapview.frame=CGRectMake(0,navView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-navView.frame.size.height);
			zoomview.frame=CGRectMake(10,10+navView.frame.size.height,38,83);
			wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70+navView.frame.size.height,wrongWay.frame.size.width,wrongWay.frame.size.height);
			[UIView commitAnimations];
			directionSearch=NO;
			[mapview computeCachedRoad];
			currentSearchType=2;
			if(!hidden)
				[self.navigationController setNavigationBarHidden:YES animated:YES];
			
		} else {
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"No driving direction can be computed using your query.",@"No driving dir. found error message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
			[alert show];
			[drivingSearchView setEditingKeyBoard];
		}
	}
	else {
		if(err.length==0) {
			
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"No driving direction can be computed using your query.",@"No driving dir. found error message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
			[alert show];
			[drivingSearchView setEditingKeyBoard];
		} else {
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:[NSString stringWithFormat:NSLocalizedString(@"Unable to retrieve the driving directions from the server: %@",@"Network error message"),err ] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
			[alert show];
			[drivingSearchView setEditingKeyBoard];
		}
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}
- (void)gpsChanged:(ChangedState*)msg {
	//NSLog(@"Receiving change for state: %@",[ChangedState stringForState:msg.state]);
	switch(msg.state) {
		case VERSION_CHANGE:
			break;
		case CONNECTION_CHANGE:
			if(![[xGPSAppDelegate gpsmanager] GetCurrentGPS].isConnected) {
				[self setGPSMode:0];
			} else {
				[self setGPSMode:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsGPSState]];
				[mapview setHasGPSPos:NO];
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
			
			
			
			if(([[[xGPSAppDelegate gpsmanager] GetCurrentGPS] isKindOfClass:[iPhone3GController class]] && [[xGPSAppDelegate gpsmanager] GetCurrentGPS].signalQuality>66) || ![[[xGPSAppDelegate gpsmanager] GetCurrentGPS] isKindOfClass:[iPhone3GController class]])
				[APPDELEGATE.gpxlogger logGPXPoint:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.latitude lon:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.longitude alt:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.altitude speed:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.speed fix:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.mode sat:[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].satellites_used];
			
			
			APPDELEGATE.directions.pos=gpsPos;
			[gpsdetails updateData];
			break;
		}case SPEED: {
			double speedms=[[[xGPSAppDelegate gpsmanager] GetCurrentGPS] gps_data].fix.speed;
			speedms*=3.6f;
			[gpsdetails updateData];
			if(speedms>3)
				[speedview setSpeed:speedms];
			else
				[speedview setSpeed:0];
		}break;
		case STATE_CHANGE:
			if([[xGPSAppDelegate gpsmanager] GetCurrentGPS].isEnabled) {
				[self setGPSMode:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsGPSState]];
				[mapview setHasGPSPos:NO];
			} else{
				[self setGPSMode:0];
			}
			break;
		case SIGNAL_QUALITY:
			[self setGPSQuality:[[xGPSAppDelegate gpsmanager] GetCurrentGPS].signalQuality];
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
