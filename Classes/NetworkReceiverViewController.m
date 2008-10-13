//
//  NetworkReceiverViewController.m
//  xGPS
//
//  Created by Mathieu on 10/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "NetworkReceiverViewController.h"

#import "xGPSAppDelegate.h"
@implementation NetworkReceiverViewController

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
	self.navigationItem.title=NSLocalizedString(@"Receiving maps",@"Receiving title");
	CGRect viewRect=[[UIScreen mainScreen] applicationFrame];
	viewRect.size.height=viewRect.size.height-44.0f;
	UIView *view=[[UIView alloc] initWithFrame:viewRect];
	self.view=view;
	self.view.backgroundColor=[UIColor whiteColor];
	UIImage *img=[UIImage imageNamed:@"wireless_future.jpg"];
	UIImageView* imgview=[[UIImageView alloc] initWithImage:img];
	CGRect size=CGRectMake((self.view.frame.size.width-img.size.width)/2.0,(self.view.frame.size.height-img.size.height)/2.0,img.size.width,img.size.height);
	imgview.frame=size;
	[self.view addSubview:imgview];
	lblStatus=[[UILabel alloc] initWithFrame:CGRectMake(0,(self.view.frame.size.height-img.size.height)/2.0+img.size.height,self.view.frame.size.width,50)];
	[self.view addSubview:lblStatus];
	lblStatus.text=NSLocalizedString(@"Ready to receive...",@"Status ready");
	lblStatus.textAlignment=UITextAlignmentCenter;
	lblStatus.font=[UIFont fontWithName:@"Helvetica" size:22];
	progress=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[progress startAnimating];
	UIBarButtonItem *btn=[[UIBarButtonItem alloc] initWithCustomView:progress];
	self.navigationItem.rightBarButtonItem=btn;
}


/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
-(void)viewWillAppear:(BOOL)animated {
	[APPDELEGATE.tiledb closeDB];
}
-(void)viewWillDisappear:(BOOL)animated {
	[APPDELEGATE.tiledb loadDB];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
