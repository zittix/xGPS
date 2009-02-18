//
//  AboutViewController.m
//  xGPS
//
//  Created by Mathieu on 10/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "AboutViewController.h"

#import "xGPSAppDelegate.h"
@implementation AboutViewController



// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
	CGRect viewRect=[[UIScreen mainScreen] applicationFrame];
	viewRect.size.height=viewRect.size.height-44.0f;
	UIWebView *view=[[UIWebView alloc] initWithFrame:viewRect];
	self.view=view;
	[view release];
	self.navigationItem.title=NSLocalizedString(@"About xGPS",@"About xGPS Title");
	NSError *err;
	NSString *license=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html" inDirectory:@"." forLocalization:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]] encoding:NSUTF8StringEncoding error:&err];
	[(UIWebView*)self.view loadHTMLString:license baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
	((UIWebView*)self.view).delegate=self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

	 if([[[request URL] scheme] isEqualToString:@"http"]) {
		[[xGPSAppDelegate appdelegate] openURL:[request URL]];
		return NO;
	}
	return YES;
}


/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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
