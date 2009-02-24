//
//  MapsManagerView.m
//  xGPS
//
//  Created by Mathieu on 6/24/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "MapsManagerView.h"
#import "Position.h"
#import "xGPSAppDelegate.h"

@implementation MapsManagerView
-(id) initWithDB:(TileDB*)_db {
	self=[super init];
	db=_db;
	
	
	pDep.x=pDep.y=pEnd.x=pEnd.y=0.0f;
	return self;
}

-(void)loadView {
	viewRect=[[UIScreen mainScreen] applicationFrame];
	self.view=[[UIView alloc] initWithFrame:viewRect];
	self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	progress=[[ProgressView alloc] initWithFrame:CGRectMake(0, 0, viewRect.size.width, viewRect.size.height)];
	mapview=[[MapView alloc] initWithFrame: CGRectMake(0, 0, viewRect.size.width, viewRect.size.height) withDB:db];
	mapview.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[mapview setGPSTracking:YES];
	self.title=NSLocalizedString(@"Maps Manager",@"Maps manager title");
	self.view.autoresizesSubviews=YES;
	[mapview setZoom: 7];
	
	
	
	self.view.multipleTouchEnabled=YES;
	[self.view addSubview: mapview];
	[progress setBtnSelector:@selector(cancelDownload) withDelegate:db];
	mapview.mapRotationEnabled=NO;
	downloading=NO;
	zoomview=[[ZoomView alloc] initWithFrame:CGRectMake(10,10,38,83) withDelegate:mapview];
	
	[self.view addSubview:zoomview];
	// add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Download",@"Download button")
																  style: UIBarButtonItemStyleDone target:self
																 action:@selector(startDownloadButton:)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	[zoomview setZoominState:YES];
	[zoomview setZoomoutState:YES];
	
}
-(void)dealloc {
	[progress release];
	[mapview release];
	[zoomview release];
	[savedName release];
	[super dealloc];
	
}
-(void)updateCurrentPos:(PositionObj*)pos {
	[mapview updateCurrentPos: pos];
	[mapview refreshMap];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[self touchesMoved:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
	NSSet *events=[event allTouches];
	
	///UITouch* value;
	//NSLog(@"Nb finger: %d",[events count]);
	if([events count]!=2) return;
	NSArray* arr=[events allObjects];
	
	CGPoint c1 = [[arr objectAtIndex:0] locationInView:mapview];
	CGPoint c2 = [[arr objectAtIndex:1] locationInView:mapview];
	
	pDep = c1;
	pEnd = c2;
	c1.y+=48;
	c2.y+=48;
	mapview.pDepForMapSelection=c1;
	mapview.pEndForMapSelection=c2;
	[mapview refreshMap];	
}

-(void)downloadTiles {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if(![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSleepMode])
		APPDELEGATE.idleTimerDisabled=YES;
	PositionObj *pos1=[mapview getPositionFromPixel:pDep.x andY:pDep.y];
	PositionObj *pos4=[mapview getPositionFromPixel:pEnd.x andY:pEnd.y];
	
	PositionObj *pos2=[mapview getPositionFromPixel:pEnd.x andY:pDep.y];
	PositionObj *pos3=[mapview getPositionFromPixel:pDep.x andY:pEnd.y];
	
	
	int x1,y1,x2,y2;
	
	[mapview getXYfrom:pos1.x andLon:pos1.y toPositionX:&x1 andY:&y1 withZoom:savedZoom];
	[mapview getXYfrom:pos4.x andLon:pos4.y toPositionX:&x2 andY:&y2 withZoom:savedZoom];
	
	
	int res=[db downloadTiles:x1 fromY:y1 toX:x2 toY:y2 withZoom:savedZoom withDelegate:progress];
	
	//NSLog(@"End of download thread");
	[progress performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
	
	NSString *msg=nil;
	if(res==0) {
		msg=NSLocalizedString(@"An error has occured while downloading the selected maps. Some parts of the maps may have not been downloaded correctly.",@"Error message download maps");
	} else if(res==1) {
		NSArray *points=[NSArray arrayWithObjects:pos1,pos2,pos3,pos4,nil];
		
		[db saveMap:savedName points:points zoom:[NSString stringWithFormat:@"%d",savedZoom]];
		msg=NSLocalizedString(@"Maps downloaded successfully !",@"Download maps ok");
	}
	[savedName release];
	savedName=nil;
	[self performSelectorOnMainThread:@selector(enableDownload) withObject:nil waitUntilDone:NO];
	
	if(msg!=nil) {
		
		[self performSelectorOnMainThread:@selector(showEndDownloadMessage:) withObject:msg waitUntilDone:YES];
		if(res==1)
			[self performSelectorOnMainThread:@selector(clearSelection) withObject:nil waitUntilDone:YES];
	}
	downloading=NO;
	if(![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSleepMode])
		APPDELEGATE.idleTimerDisabled=NO;
	[pool release];
}
-(void)clearSelection {
	pDep.x=pDep.y=pEnd.x=pEnd.y=0.0f;
	mapview.pDepForMapSelection=pDep;
	mapview.pEndForMapSelection=pEnd;
	[mapview refreshMap];
}
-(void)enableDownload {
	self.navigationItem.rightBarButtonItem.enabled=YES;
}
-(void)showEndDownloadMessage:(NSString*)msg {
	UIAlertView* hotSheet = [[UIAlertView alloc]
							 initWithTitle:NSLocalizedString(@"Maps Download",@"Maps Download title message box")
							 message: msg
							 delegate:nil
							 cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss")
							 otherButtonTitles:nil];
	
	[hotSheet show];	
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
	
	
	if(buttonIndex==1) {
		savedName=nil;
		detailView=YES;
		MapsDownloadDetailsViewController *controller=[[MapsDownloadDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped delegate:self];
		[self.navigationController pushViewController:controller animated:YES];
	}
}
- (void)viewWillDisappear:(BOOL)animated {
	[db cancelDownload];
	[progress hide];
	self.navigationItem.rightBarButtonItem.enabled=YES;
	if(!detailView)
	[self clearSelection];
}

- (void)viewWillAppear:(BOOL)animated {
	if(!detailView) {
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:kSettingsMapType]==0)
		mapview.maxZoom=17;
	else
		mapview.maxZoom=15;
	
	savedZoom=17-mapview.maxZoom;
	
	if(mapview.zoom<17-mapview.maxZoom)
		[mapview setZoom:17-mapview.maxZoom];
	else
		[mapview setZoom:mapview.zoom];
	[mapview fulllRefreshMap];
	mapview.mapRotationEnabled=NO;
	}

}
-(void)viewDidAppear:(BOOL)animated {
	if(detailView && savedName!=nil) {

	downloading=YES;
	[progress setProgress:0];
	progress.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	[progress showFrom:self.view];
	self.navigationItem.rightBarButtonItem.enabled=NO;
	[NSThread detachNewThreadSelector:@selector(downloadTiles) toTarget:self withObject:nil];	
	
	}
	mapview.mapRotationEnabled=NO;
	detailView=NO;
}
-(void)gotName:(NSString*)name andZoomLevel:(int)z {
	savedName=[name retain];
	savedZoom=z;
}
- (void)startDownloadButton:(id)sender
{
	PositionObj *pos1=[mapview getPositionFromPixel:pDep.x andY:pDep.y-48.0f];
	PositionObj *pos2=[mapview getPositionFromPixel:pEnd.x andY:pEnd.y-48.0f];
	
	int x1,y1,x2,y2;
	
	//TODO: Let the user choosing the zoom
	[mapview getXYfrom:pos1.x andLon:pos1.y toPositionX:&x1 andY:&y1 withZoom:savedZoom];
	[mapview getXYfrom:pos2.x andLon:pos2.y toPositionX:&x2 andY:&y2 withZoom:savedZoom];
	
	if(abs(x2-x1)>0 && abs(y2-y1)>0 ) {
		
		int nb=abs(x2-x1)*abs(y2-y1);
		double kb=abs(x2-x1)*abs(y2-y1)*3.6;
		NSString *msg;
		if(kb>1000) {
			kb/=1024.0;
			msg=[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to download the selected map area (%d tiles ~ %.1f MB) ?",@"Make sure to let the %d etc..."),nb,kb];
		} else {
			msg=[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to download the selected map area (%d tiles ~ %.1f KB) ?",@"in kilo bytes"),nb,kb];
		}
		
		UIAlertView * hotSheet = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"Maps Download",@"Maps Download title message box")
								  message:msg
								  delegate:self
								  cancelButtonTitle:NSLocalizedString(@"No",@"No")
								  otherButtonTitles:NSLocalizedString(@"Yes",@"Yes"),nil];
		
		[hotSheet show];
		
	} else {
		[self showEndDownloadMessage:NSLocalizedString(@"Please select a greater map area by touching the screen with two fingers.",@"Error map select message")];
	}
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[mapview refreshMap];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end