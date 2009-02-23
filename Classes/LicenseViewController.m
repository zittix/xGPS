//
//  LicenseViewController.m
//  xGPS
//
//  Created by Mathieu on 9/18/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "LicenseViewController.h"
#import "xGPSAppDelegate.h"

@implementation LicenseViewController



// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
	CGRect viewRect=[[UIScreen mainScreen] applicationFrame];
	self.view=[[UIWebView alloc] initWithFrame:viewRect];
	[self.view release];
	NSError *err;
	NSString *license=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"license" ofType:@"html" inDirectory:@"." forLocalization:[[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]] encoding:NSUTF8StringEncoding error:&err];
	[(UIWebView*)self.view loadHTMLString:license baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
	((UIWebView*)self.view).delegate=self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *path=[[request URL] path];
	//NSLog([[request URL] scheme]);
	if(path!=nil && [path isEqualToString:@"/iagree"]) {
		[self.navigationController dismissModalViewControllerAnimated:YES];
		return NO;
	} else if([[[request URL] scheme] isEqualToString:@"http"]) {
		[[xGPSAppDelegate appdelegate] openURL:[request URL]];
		return NO;
	}
	return YES;
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
