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
	mapview=[[MapView alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,viewRect.size.height) withDB:tiledb];
	mapview.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	viewSearch=[[ViewSearch alloc] initWithFrame:CGRectMake(0,0,viewRect.size.width,viewRect.size.height) delegate:self];
	viewSearch.frame=CGRectMake(viewRect.size.width/2.0,viewRect.size.height/2.0,1,1);
	[self.view addSubview:mapview];
	zoomview=[[ZoomView alloc] initWithFrame:CGRectMake(10,10,38,83) withDelegate:mapview];
	[self.view addSubview:zoomview];
	speedview=[[SpeedView alloc] initWithFrame:CGRectMake(2.0f,viewRect.size.height-95.0f-2.0f-44.0f,92.0f,100.0f)];
	[speedview setSpeed:0];
	
	//[self.view addSubview:speedview];
	speedview.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;


	[self.view addSubview:speedview];

	//btnSettings=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings",@"Settings Button") style:UIBarButtonItemStyleBordered target:self action:@selector(settingsBtnPressed:)];
	//btnSettings=[[UIButton alloc] initWithImage:[UIImage imageNamed:@"settingsIcon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(settingsBtnPressed:)];
	//btnSearch=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBtnPressed:)];
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
	
	signalView=[[GPSSignalView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-58,5,47,40) delegate:self];
	signalView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self.view addSubview:signalView];
	[signalView setQuality:-1];
	
	speedview.hidden=YES;
	signalView.hidden=YES;
	cancelSearch=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelDrivingSearch:)];
	routesManager=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Manager",@"") style:UIBarButtonItemStyleBordered target:self action:@selector(showManager:)];
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
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsLastUsedBookmark]>=0) {
		NSMutableArray *road=[APPDELEGATE.dirbookmarks copyBookmarkRoadPoints:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsLastUsedBookmark]];
		NSMutableArray *instr=[APPDELEGATE.dirbookmarks copyBookmarkInstructions:[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsLastUsedBookmark]];
		[APPDELEGATE.directions setRoad:road instructions:instr];
		[road release];
		[instr release];
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
	[UIView beginAnimations:nil context:nil];
	[self.view addSubview:searchPlacesView];
	[UIView commitAnimations];
	[self hideViewSearch];
}
-(void)btnSearchRoutePressed {
	directionSearch=YES;
	self.navigationItem.leftBarButtonItem.enabled=YES;
	self.navigationItem.rightBarButtonItem.enabled=YES;
	[UIView beginAnimations:nil context:nil];
	[self.view addSubview:drivingSearchView];
	self.navigationController.navigationBarHidden=NO;
	self.navigationItem.title=NSLocalizedString(@"Directions",@"");
	self.navigationItem.rightBarButtonItem=cancelSearch;
	self.navigationItem.leftBarButtonItem=routesManager;
	[mapview refreshMap];
	[UIView commitAnimations];
	[self hideViewSearch];
}
-(void)btnRoutesManagerPressed {
	[self hideViewSearch];
	[self showManager:nil];
}
-(void)btnHomePressed {
	[self hideViewSearch];
}
-(void)hideViewSearch {
	[UIView beginAnimations:nil context:nil];
	viewSearch.frame=CGRectMake(self.view.frame.size.width/2.0,self.view.frame.size.height/2.0,0,0);
	[viewSearch removeFromSuperview];
	[UIView commitAnimations];
}
-(void)btnClearPressed {
	if(currentSearchType==1) {
		[mapview setPosSearch:nil];
	} else if(currentSearchType==2) {
		[self clearDirections];
	}
	currentSearchType=0;
	[self hideViewSearch];
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
		
		if([stopDate compare:startDate]==NSOrderedAscending)
			stopDate=[stopDate addTimeInterval:24*60*60];
		NSDate *curDate=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d:%d",actHour,actMinute]];
		NSComparisonResult resStart=[curDate compare:startDate];
		NSComparisonResult resStop=[curDate compare:stopDate];
		[dateFormatter release];
		if((resStart==NSOrderedSame || resStart==NSOrderedDescending) && resStop==NSOrderedAscending) {
			if(mapview.nightMode!=YES) {
				[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];	
				[navView setNightMode:YES];
				mapview.nightMode=YES;
				[mapview refreshMap];
			}
		} else {
			if(mapview.nightMode==YES) {
				[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
				mapview.nightMode=NO;
				[navView setNightMode:NO];
				[mapview refreshMap];
			}
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
			[mapview refreshMap];
		} else {
			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
			mapview.nightMode=NO;
			[navView setNightMode:NO];
			[mapview refreshMap];
		}
	} else {
		[self timerNightMode];	
	}
	if(![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsNightModeEnabled]) {
		[self hideWrongWay];
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
	
	[wrongWay removeFromSuperview];
	
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
	[viewSearch release];
	[speedview release];
	[btnSettings release];
	[btnSearch release];
	[settingsController release];
	[signalView release];
	[searchPlacesView release];
	[gpsPos release];
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
	[super viewDidAppear:animated];
}
-(void) endRotation:(NSString*)animationID finished:(BOOL)finished context:(NSString*)context {
	[self.navigationController pushViewController:settingsController animated:YES];
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if(!directionSearch)
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	
	[UIView beginAnimations:nil context:nil];
	
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
	[navView sizeToFit];
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
		[signalView setQuality:-1];
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
	[self.view addSubview:viewSearch];
	[UIView beginAnimations:nil context:nil];
	viewSearch.frame=mapview.frame;
	[UIView commitAnimations];
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
	mapview.frame=CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
	zoomview.frame=CGRectMake(10,10,38,83);
	wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70,wrongWay.frame.size.width,wrongWay.frame.size.height);
	signalView.frame=CGRectMake(self.view.frame.size.width-58,5,47,40);
	[UIView commitAnimations];
	[APPDELEGATE.directions clearResult];
	currentSearchType=0;
	[wrongWay stopAnimate];
	[wrongWay removeFromSuperview];
}
-(void)nextDirectionChanged:(Instruction*)instr {
	//if(instr.dist<500)
	//	[navView setText:[NSString stringWithFormat:@"%@\nIn %.1f m",instr.name,instr.dist]];
	//else
	//	[navView setText:[NSString stringWithFormat:@"%@\nIn %.1f km",instr.name,instr.dist/1000.0]];
	[navView setText:instr.name];
	[UIView beginAnimations:nil context:nil];	
	[navView sizeToFit];
	mapview.frame=CGRectMake(0,navView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-navView.frame.size.height);
	zoomview.frame=CGRectMake(10,10+navView.frame.size.height,38,83);
	wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70+navView.frame.size.height,wrongWay.frame.size.width,wrongWay.frame.size.height);
	signalView.frame=CGRectMake(self.view.frame.size.width-58,5+navView.frame.size.height,47,40);
	[UIView commitAnimations];
	
}
-(void)nextDirectionDistanceChanged:(double)dist {
	
}
-(void)gotResultForSearch:(GeoEncoderResult*)res {
	[mapview setPosSearch:res.pos];
	currentSearchType=1;
}
-(void)directionsGot:(NSString*)from to:(NSString*)to error:(NSError*)err {
	self.navigationItem.leftBarButtonItem.enabled=YES;
	self.navigationItem.rightBarButtonItem.enabled=YES;
	[self dismissModalViewControllerAnimated:YES];
	if(err==nil) {
		
		//Search the first instruction
		if([APPDELEGATE.directions.instructions count]>0) {
			
			
			[UIView beginAnimations:nil context:nil];	
			[drivingSearchView removeFromSuperview];
			
			self.navigationItem.title=@"xGPS";
			self.navigationItem.rightBarButtonItem=nil;
			self.navigationItem.leftBarButtonItem=nil;
			[self.view addSubview:navView];
			mapview.frame=CGRectMake(0,navView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-navView.frame.size.height);
			zoomview.frame=CGRectMake(10,10+navView.frame.size.height,38,83);
			wrongWay.frame=CGRectMake(self.view.frame.size.width-140,70+navView.frame.size.height,wrongWay.frame.size.width,wrongWay.frame.size.height);
			signalView.frame=CGRectMake(self.view.frame.size.width-58,5+navView.frame.size.height,47,40);
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
