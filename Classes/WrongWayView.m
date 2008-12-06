//
//  WrongWayView.m
//  xGPS
//
//  Created by Mathieu on 26.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WrongWayView.h"
#import "xGPSAppDelegate.h"
#import "MainViewController.h"
@implementation WrongWayView


- (id)initWithFrame:(CGRect)frame withDelegate:(MainViewController*)_del{
    if ((self = [super initWithFrame:CGRectMake(frame.origin.x,frame.origin.y,130,82)])) {
		UIImageView* back=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wrongway.png"]];
		[self addSubview:back];
		[back release];
		delegate=_del;
		wrongWaylbl=[[UILabel alloc] initWithFrame:CGRectMake(13,13,104,56)];
		wrongWaylbl.backgroundColor=[UIColor clearColor];
		self.backgroundColor=[UIColor clearColor];
		wrongWaylbl.numberOfLines=0;
		wrongWaylbl.textColor=[UIColor whiteColor];
		wrongWaylbl.font=[UIFont boldSystemFontOfSize:21];
		wrongWaylbl.textAlignment=UITextAlignmentCenter;
		wrongWaylbl.minimumFontSize=10;
		wrongWaylbl.highlighted=YES;
		wrongWaylbl.adjustsFontSizeToFitWidth=YES;
		wrongWaylbl.text=NSLocalizedString(@"Wrong\nWay",@"");
		
		[self addSubview:wrongWaylbl];
    }
    return self;
}
-(void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	if(!run) return;
	[UIView beginAnimations:@"animWrongWay" context:nil];
	[UIView setAnimationDelegate:self];
	
	[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
	if(self.alpha<0.5) {
		[UIView setAnimationDuration:0.3];
		self.alpha=1;
	}else{
		[UIView setAnimationDuration:0.8];
		self.alpha=0.1;
	}
	[UIView commitAnimations];
}
-(void)startAnimate {
	if(run) return;
	run=YES;
	[UIView beginAnimations:@"animWrongWay" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
	if(self.alpha<0.5) {
		[UIView setAnimationDuration:0.3];
		self.alpha=1;
	}else{
		[UIView setAnimationDuration:0.8];
		self.alpha=0.1;
	}
	[UIView commitAnimations];
}
-(void)stopAnimate {
	run=NO;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex==1) {
		[self stopAnimate];
		[self removeFromSuperview];
		NSString *to=[APPDELEGATE.directions.to retain];
		float lat=APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.latitude;
		float lon=APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.longitude;
		char latD='N';
		char lonD='E';
		if(lat<0) {
			lat*=-1;
			latD='S';
		}
		if(lon<0) {
			lon*=-1;
			lonD='S';
		}
		NSString*from=[[NSString alloc] initWithFormat:@"%f%c,%f%c",lat,latD,lon,lonD];
		[delegate clearDirections];
		[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
		[APPDELEGATE.directions drive:from to:to];
		[from release];
		[to release];
	}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet * set=[event touchesForView:self];
	if([set count]==1) {
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Driving directions",@"") message:NSLocalizedString(@"Are you sure you want to recompute the itinerary from the current position ?",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"No",@"No") otherButtonTitles:NSLocalizedString(@"Yes",@"Yes"),nil];
		[alert show];
		
	}
}
- (void)dealloc {
    [super dealloc];
}


@end
