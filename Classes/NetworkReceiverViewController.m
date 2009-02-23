//
//  NetworkReceiverViewController.m
//  xGPS
//
//  Created by Mathieu on 10/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "NetworkReceiverViewController.h"

#import "xGPSAppDelegate.h"

#define USE_SIMULATOR

#ifndef USE_SIMULATOR
@interface NSHost
-(NSString*)address;
+(NSHost*)currentHost;
@end
#endif
@implementation NetworkReceiverViewController


// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
	self.navigationItem.title=NSLocalizedString(@"Transfer",@"Receiving title");
	CGRect viewRect=[[UIScreen mainScreen] applicationFrame];
	viewRect.size.height=viewRect.size.height-44.0f;
	UIView *view=[[UIView alloc] initWithFrame:viewRect];
	self.view=view;
	[view release];
	self.view.autoresizesSubviews=YES;
	self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor=[UIColor whiteColor];
	UIImage *img=[UIImage imageNamed:@"wireless_future.jpg"];
	UIImageView* imgview=[[UIImageView alloc] initWithImage:img];
	CGRect size=CGRectMake((self.view.frame.size.width-img.size.width)/2.0,(self.view.frame.size.height-img.size.height)/2.0,img.size.width,img.size.height);
	
	imgview.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	
	imgview.frame=size;
	[self.view addSubview:imgview];
	[imgview release];
	lblStatus=[[UILabel alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-50,self.view.frame.size.width,50)];
	lblAddress=[[UILabel alloc] initWithFrame:CGRectMake(0,5,self.view.frame.size.width,20)];
	lblAddress.text=[NSString stringWithFormat:NSLocalizedString(@"Device address: %@",@""),[self getIPAddress]];
	lblAddress.adjustsFontSizeToFitWidth=YES;
	lblAddress.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	lblAddress.textAlignment=UITextAlignmentCenter;
	lblAddress.font=[UIFont systemFontOfSize:16];
	lblAddress.backgroundColor=[UIColor clearColor];
	
	lblStatus.text=NSLocalizedString(@"Ready to transfer...",@"Status ready");
	lblStatus.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	lblStatus.textAlignment=UITextAlignmentCenter;
	lblStatus.font=[UIFont systemFontOfSize:22];
	lblStatus.backgroundColor=[UIColor clearColor];
	lblStatus.textColor=[UIColor darkGrayColor];
	
	
	[self.view addSubview:lblAddress];
	
	[self.view addSubview:lblStatus];
	
	UIActivityIndicatorView *progress=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[progress startAnimating];
	UIBarButtonItem *btn=[[UIBarButtonItem alloc] initWithCustomView:progress];
	self.navigationItem.rightBarButtonItem=btn;
	[btn release];
	[progress release];
	
	
	
	APPDELEGATE.txcontroller.delegate=self;
}
-(NSString*)getIPAddress {
	NSHost* myhost =[NSHost currentHost];
	if (myhost)
		return [myhost address];
	else
		return NSLocalizedString(@"Unknown",@"");
		
}

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
-(void)viewWillAppear:(BOOL)animated {
	[APPDELEGATE.tiledb closeDB];
	[APPDELEGATE.dirbookmarks close];
	[APPDELEGATE.txcontroller startServer];
	lblStatus.text=NSLocalizedString(@"Ready to transfer...",@"Status ready");
}
-(void)viewWillDisappear:(BOOL)animated {
	[APPDELEGATE.tiledb loadDB];
	[APPDELEGATE.dirbookmarks load];
	[APPDELEGATE.txcontroller stopServer];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void)txstatusChanged:(NSString*)s {
	lblStatus.text=s;
}
- (void)dealloc {
    [super dealloc];
	[lblStatus release];
	[lblAddress release];
}


@end
