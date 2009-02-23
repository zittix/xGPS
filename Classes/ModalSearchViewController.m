//
//  ModalSearchViewController.m
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ModalSearchViewController.h"


@implementation ModalSearchViewController

-(id)initWithDelegate:(id<SearchPlacesViewDelegate>)del {
	if((self=[super init])) {
	delegate=del;
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[self.view release];
	self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.title=NSLocalizedString(@"Search",@"");
	searchPlacesView=[[SearchPlacesView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) andController:self delegate:self];
	searchPlacesView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	searchPlacesView.autoresizesSubviews=YES;
	[self.view addSubview:searchPlacesView];
}

-(void)gotResultForSearch:(GeoEncoderResult*)r {
	[delegate gotResultForSearch:r];
}
-(void) searchPlaceWillHide {
	[delegate searchPlaceWillHide];
}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

-(void)setLocation:(BOOL)val {
	searchPlacesView.location=val;
}
-(BOOL)location {
	return searchPlacesView.location;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[searchPlacesView release];
    [super dealloc];
}


@end
