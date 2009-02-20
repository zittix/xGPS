//
//  ProgressViewController.m
//  xGPS
//
//  Created by Mathieu on 20.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProgressViewController.h"


@implementation ProgressViewController

@synthesize progress;
- (id)init {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super init]) {
		CGRect viewRect=[[UIScreen mainScreen] applicationFrame];
		progress=[[ProgressView alloc] initWithFrame:viewRect];
    }
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	
	progress.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.view=progress;	
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[progress release];
    [super dealloc];
}


@end
