//
//  ViewSearch.m
//  xGPS
//
//  Created by Mathieu on 23.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ViewSearch.h"

#define BUTTON_SIZE 100.0f
@implementation ViewSearch


-(id)initWithFrame:(CGRect)frame delegate:(id<ViewSearchProtocol>)_delegate {
    if (self = [super initWithFrame:frame]) {
		bg=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_search.png"]];
		[self addSubview:bg];
		self.autoresizesSubviews=YES;
		self.backgroundColor=[UIColor clearColor];
		self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		bg.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		searchPlace=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		searchPlace.showsTouchWhenHighlighted=YES;
		[searchPlace setBackgroundImage:[UIImage imageNamed:@"search_places.png"] forState:UIControlStateNormal];
		[searchPlace setTitle:NSLocalizedString(@"Search Places",@"") forState:UIControlStateNormal];
		searchPlace.font=[UIFont systemFontOfSize:10];
		searchPlace.titleEdgeInsets=UIEdgeInsetsMake(80,0,2,0);
		
		float horSpace=(self.frame.size.width-2*BUTTON_SIZE)/3.0;
		
		searchPlace.frame=CGRectMake(horSpace, 30, BUTTON_SIZE, BUTTON_SIZE);
		searchPlace.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
		
		searchRoute=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		searchRoute.showsTouchWhenHighlighted=YES;
		[searchRoute setBackgroundImage:[UIImage imageNamed:@"routes.png"] forState:UIControlStateNormal];
		[searchRoute setTitle:NSLocalizedString(@"Driving directions",@"") forState:UIControlStateNormal];
		searchRoute.frame=CGRectMake(2*horSpace+BUTTON_SIZE, 30, BUTTON_SIZE, BUTTON_SIZE);
		searchRoute.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
		searchRoute.font=[UIFont systemFontOfSize:10];
		searchRoute.titleEdgeInsets=UIEdgeInsetsMake(80,0,2,0);
		
		
		home=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		home.showsTouchWhenHighlighted=YES;
		[home setBackgroundImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
		home.font=[UIFont systemFontOfSize:10];
		home.titleEdgeInsets=UIEdgeInsetsMake(80,0,2,0);
		home.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
		
		home.frame=CGRectMake(horSpace, 60+BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE);
		[home setTitle:NSLocalizedString(@"Go Home",@"") forState:UIControlStateNormal];
		routesManager=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		routesManager.showsTouchWhenHighlighted=YES;
		[routesManager setBackgroundImage:[UIImage imageNamed:@"route_manager.png"] forState:UIControlStateNormal];
		[routesManager setTitle:NSLocalizedString(@"Routes Manager",@"") forState:UIControlStateNormal];
		routesManager.frame=CGRectMake(2*horSpace+BUTTON_SIZE, 60+BUTTON_SIZE, BUTTON_SIZE,BUTTON_SIZE);
		routesManager.font=[UIFont systemFontOfSize:10];
		routesManager.titleEdgeInsets=UIEdgeInsetsMake(80,0,2,0);
		routesManager.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
		clear=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[clear setTitle:NSLocalizedString(@"Clear Results",@"") forState:UIControlStateNormal];
		[clear setBackgroundImage:[UIImage imageNamed:@"clear_results.png"] forState:UIControlStateNormal];
		clear.frame=CGRectMake((self.frame.size.width-180)/2.0, 50+2*BUTTON_SIZE, 180, 55);
		clear.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

		close=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[close setTitle:NSLocalizedString(@"Close",@"") forState:UIControlStateNormal];
		[close setBackgroundImage:[UIImage imageNamed:@"clear_results.png"] forState:UIControlStateNormal];
		close.frame=CGRectMake((self.frame.size.width-180)/2.0, 50+2*BUTTON_SIZE+70, 180, 55);
		close.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

		
		[self addSubview:searchPlace];
		[self addSubview:searchRoute];
		[self addSubview:home];
		[self addSubview:routesManager];
		[self addSubview:clear];
		[self addSubview:close];
		
		[searchPlace addTarget:_delegate action:@selector(btnSearchPlacePressed) forControlEvents:UIControlEventTouchUpInside];
		[clear addTarget:_delegate action:@selector(btnClearPressed) forControlEvents:UIControlEventTouchUpInside];
		[routesManager addTarget:_delegate action:@selector(btnRoutesManagerPressed) forControlEvents:UIControlEventTouchUpInside];
		[searchRoute addTarget:_delegate action:@selector(btnSearchRoutePressed) forControlEvents:UIControlEventTouchUpInside];
		[home addTarget:_delegate action:@selector(btnHomePressed) forControlEvents:UIControlEventTouchUpInside];
		[close addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
		
    }
    return self;
}

-(void)showButton {
	[UIView beginAnimations:nil context:nil];
	clear.alpha=1;
	routesManager.alpha=1;
	searchRoute.alpha=1;
	home.alpha=1;
	searchPlace.alpha=1;
	close.alpha=1;
	[UIView commitAnimations];
}

-(void)showInView:(UIView*)view {
	self.frame=CGRectMake(view.frame.size.width/2.0,view.frame.size.height/2.0,0,0);
	clear.alpha=0;
	routesManager.alpha=0;
	searchRoute.alpha=0;
	home.alpha=0;
	searchPlace.alpha=0;
	close.alpha=0;
	[view addSubview:self];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showButton)];
	self.frame=view.frame;
	[UIView commitAnimations];
	
	
}
-(void)hide {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideView)];
	clear.alpha=0;
	routesManager.alpha=0;
	searchRoute.alpha=0;
	home.alpha=0;
	close.alpha=0;
	searchPlace.alpha=0;
	[UIView commitAnimations];
}
-(void)hideView {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeView)];
	self.frame=CGRectMake(self.frame.size.width/2.0,self.frame.size.height/2.0,0,0);
	[UIView commitAnimations];
	
}

-(void)removeView {
	[self removeFromSuperview];	
}

- (void)layoutIfNeeded {
}
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

-(void)changeOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		[bg setImage:[UIImage imageNamed:@"bg_search.png"]];
		//clear.frame=CGRectMake((self.frame.size.width-130)/2.0, 100+2*BUTTON_SIZE, 136, 55);
		//close.frame=CGRectMake((self.frame.size.width-130)/2.0, 100+2*BUTTON_SIZE+70, 136, 55);
		
	} else {
		[bg setImage:[UIImage imageNamed:@"bg_search_landscape.png"]];
		//clear.frame=CGRectMake((self.frame.size.width-130)/2.0, (self.frame.size.height-70-55)/2.0, 136, 55);
		//close.frame=CGRectMake((self.frame.size.width-130)/2.0, (self.frame.size.height-70-55)/2.0+70, 136, 55);
	}
}
- (void)dealloc {
	[bg release];
    [super dealloc];
}


@end
