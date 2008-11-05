//
//  main.m
//  xGPS
//
//  Created by Mathieu on 7/30/08.
//  Copyright Xwaves 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//float a=log(6.30723855265);
	
	//NSLog(@"%f",log(val));
	int retVal = UIApplicationMain(argc, argv, @"xGPSAppDelegate", @"xGPSAppDelegate");
	[pool release];
	return retVal;
}

