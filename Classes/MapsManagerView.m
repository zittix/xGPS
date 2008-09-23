//
//  MapsManagerView.m
//  xGPS
//
//  Created by Mathieu on 6/24/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "MapsManagerView.h"
#import "Position.h"
@implementation MapsManagerView
-(id) initWithDB:(TileDB*)_db {
	self=[super init];
		db=_db;
	
	
		pDep.x=pDep.y=pEnd.x=pEnd.y=0.0f;
	return self;
}

-(void)loadView {
	viewRect=[[UIScreen mainScreen] applicationFrame];
	self.view=[[OverlayView alloc] initWithFrame:viewRect];
	viewOverlay=(OverlayView*)self.view;
	viewRect.origin.y=0;
	progress=[[ProgressView alloc] initWithFrame:viewRect];
	mapview=[[MapView alloc] initWithFrame: CGRectMake(viewRect.origin.x, viewRect.origin.y, viewRect.size.width, viewRect.size.height-48.0f) withDB:db];
	self.title=NSLocalizedString(@"Maps Manager",@"Maps manager title");
	[mapview setZoom: 7];
	self.view.multipleTouchEnabled=YES;
	[self.view addSubview: mapview];
	[mapview setPassDoubleFingersEvent:YES];
	[progress setBtnSelector:@selector(cancelDownload) withDelegate:db];
	
	downloading=NO;
	zoomview=[[ZoomView alloc] initWithFrame:CGRectMake(10,70,100,100) withDelegate:mapview];
	[self.view addSubview:zoomview];
	// add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Download",@"Download button")
																  style: UIBarButtonItemStyleDone target:self
																			   action:@selector(startDownloadButton:)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
}
-(void)updateCurrentPos:(PositionObj*)pos {
	[mapview updateCurrentPos: pos];
	[mapview setNeedsDisplay];
}

-(void)setOrientation:(int)_orientation {
	[mapview setOrientation:_orientation];
	orientation=_orientation;
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
	
	CGPoint c1 = [[arr objectAtIndex:0] locationInView:self.view];
	CGPoint c2 = [[arr objectAtIndex:1] locationInView:self.view];
	c1.y+=48;
	c2.y+=48;
	pDep = c1;
	pEnd = c2;
	viewOverlay.pDep=pDep;
	viewOverlay.pEnd=pEnd;
	[mapview setNeedsDisplay];	
}

-(void)downloadTiles {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	PositionObj *pos1=[mapview getPositionFromPixel:pDep.x andY:pDep.y-48.0f];
	PositionObj *pos2=[mapview getPositionFromPixel:pEnd.x andY:pEnd.y-48.0f];

	int x1,y1,x2,y2;

	//TODO: Let the user choosing the zoom
	[MapView getXYfrom:pos1.x andLon:pos1.y toPositionX:&x1 andY:&y1 withZoom:0];
	[MapView getXYfrom:pos2.x andLon:pos2.y toPositionX:&x2 andY:&y2 withZoom:0];

	int res=[db downloadTiles:x1 fromY:y1 toX:x2 toY:y2 withZoom:0 withDelegate:progress];

	NSLog(@"End of download thread");
	[progress performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];

	NSString *msg=nil;
	if(res==0) {
		msg=NSLocalizedString(@"An error has occured while downloading the selected maps. Some parts of the maps may have not been downloaded correctly.",@"Error message download maps");
	} else if(res==1) {
		msg=NSLocalizedString(@"Maps downloaded successfully !",@"Download maps ok");
	}
	if(msg!=nil) {
		[self performSelectorOnMainThread:@selector(showEndDownloadMessage:) withObject:msg waitUntilDone:YES];
		if(res==1)
		[self performSelectorOnMainThread:@selector(clearSelection) withObject:nil waitUntilDone:YES];
	}
	downloading=NO;
	[pool release];
}
-(void)clearSelection {
	pDep.x=pDep.y=pEnd.x=pEnd.y=0.0f;
	viewOverlay.pDep=pDep;
	viewOverlay.pEnd=pEnd;
	[mapview setNeedsDisplay];
}
-(void)showEndDownloadMessage:(NSString*)msg {
	UIAlertView* hotSheet = [[UIAlertView alloc]
							 initWithTitle:NSLocalizedString(@"Maps Download",@"Maps Download title message box")
							 message: msg
							 delegate:nil
							 cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Close button of message box")
							 otherButtonTitles:nil];

	[hotSheet show];	
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
	if(buttonIndex==1) {
		downloading=YES;
		[progress setProgress:0];
		[progress showFrom:self.view];

		[NSThread detachNewThreadSelector:@selector(downloadTiles) toTarget:self withObject:nil];
	}
}
- (void)startDownloadButton:(id)sender
{
	NSLog(@"Start downloading button...");
			PositionObj *pos1=[mapview getPositionFromPixel:pDep.x andY:pDep.y-48.0f];
			PositionObj *pos2=[mapview getPositionFromPixel:pEnd.x andY:pEnd.y-48.0f];

			int x1,y1,x2,y2;

			//TODO: Let the user choosing the zoom
			[MapView getXYfrom:pos1.x andLon:pos1.y toPositionX:&x1 andY:&y1 withZoom:0];
			[MapView getXYfrom:pos2.x andLon:pos2.y toPositionX:&x2 andY:&y2 withZoom:0];

			if(abs(x2-x1)>0 && abs(y2-y1)>0 ) {

				int nb=abs(x2-x1)*abs(y2-y1);
				int kb=abs(x2-x1)*abs(y2-y1)*6;
				NSString *msg;
				if(kb>1000) {
					kb/=1024;
					msg=[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to download the selected map area (%d tiles ~ %d MB) ?",@"Make sure to let the %d etc..."),nb,kb];
				} else {
					msg=[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to download the selected map area (%d tiles ~ %d KB) ?",@"in kilo bytes"),nb,kb];
				}

				UIAlertView * hotSheet = [[UIAlertView alloc]
				initWithTitle:NSLocalizedString(@"Maps Download",@"Maps Download title message box")
										  message:msg
										  delegate:self
										  cancelButtonTitle:NSLocalizedString(@"No",@"No button")
										  otherButtonTitles:NSLocalizedString(@"Yes",@"Yes Button"),nil];
				
				[hotSheet show];

			} else {
				[self showEndDownloadMessage:NSLocalizedString(@"Please select a greater map area by touching the screen with two fingers.",@"Error map select message")];
			}
}
@end
@implementation OverlayView
@synthesize pDep;
@synthesize pEnd;


-(void)drawRect:(CGRect)rect {
	//NSLog(@"OverLayview draw");
	if(pDep.x==0.0f && pDep.y==0.0f && pEnd.x==0.0f && pEnd.y==0.0f)
	return;

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context,1,0,0,0.4);
	CGContextSetRGBStrokeColor(context,1,0,0,0.8);

	CGPoint org;
	CGSize size;

	//if(orientation==0 || orientation==180) {
		org=CGPointMake(pDep.x >= 0 ? pDep.x : 0,pDep.y-48.0f >= 0 ? pDep.y-48.0f : 0);
		size=CGSizeMake(pEnd.x-pDep.x,pEnd.y-pDep.y);
	/*} else if(orientation==90) {
		org=CGPointMake(pDep.y >= 0 ? pDep.y : 0,pDep.x-48.0f >= 0 ? rect.size.height-pDep.x : 0);
		size=CGSizeMake(pEnd.y-pDep.y,pEnd.x-pDep.x);
	} else {
		org=CGPointMake(pDep.y >= 0 ? pDep.y : 0,pDep.x-48.0f >= 0 ? rect.size.height-pDep.x : 0);
		size=CGSizeMake(pEnd.y-pDep.y,pEnd.x-pDep.x);
	}*/

	//NSLog(@"Origin: %f %f",org.x,org.y);
	//NSLog(@"Size: %f %f",size.width,size.height);
	CGContextFillRect(context,CGRectMake(org.x,org.y,size.width,size.height));
	CGContextStrokeRectWithWidth(context,CGRectMake(org.x,org.y,size.width,size.height),4);
}
@end