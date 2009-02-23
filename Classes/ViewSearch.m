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
		self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		bg.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		searchPlace=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		searchPlace.showsTouchWhenHighlighted=YES;
		[searchPlace setImage:[UIImage imageNamed:@"search_places.png"] forState:UIControlStateNormal];

		float horSpace=(self.frame.size.width-2*BUTTON_SIZE)/3.0;
		
		searchPlace.frame=CGRectMake(horSpace, 30, BUTTON_SIZE, BUTTON_SIZE);
		//searchPlace.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
		
		searchRoute=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		searchRoute.showsTouchWhenHighlighted=YES;
		[searchRoute setImage:[UIImage imageNamed:@"routes.png"] forState:UIControlStateNormal];
		
		searchRoute.frame=CGRectMake(2*horSpace+BUTTON_SIZE, 30, BUTTON_SIZE, BUTTON_SIZE);
		//searchRoute.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
		
		home=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		home.showsTouchWhenHighlighted=YES;
		[home setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
		
		home.frame=CGRectMake(horSpace, 60+BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE);
		
		routesManager=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		routesManager.showsTouchWhenHighlighted=YES;
		[routesManager setImage:[UIImage imageNamed:@"route_manager.png"] forState:UIControlStateNormal];
		
		routesManager.frame=CGRectMake(2*horSpace+BUTTON_SIZE, 60+BUTTON_SIZE, BUTTON_SIZE,BUTTON_SIZE);
		
		clear=[[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[clear setTitle:NSLocalizedString(@"Clear Results",@"") forState:UIControlStateNormal];
		[clear setBackgroundImage:[UIImage imageNamed:@"clear_results.png"] forState:UIControlStateNormal];
		clear.frame=CGRectMake((self.frame.size.width-130)/2.0, 100+2*BUTTON_SIZE, 136, 55);
		clear.backgroundColor=[UIColor clearColor];
		[self addSubview:searchPlace];
		[self addSubview:searchRoute];
		[self addSubview:home];
		[self addSubview:routesManager];
		[self addSubview:clear];
		
		[searchPlace addTarget:_delegate action:@selector(btnSearchPlacePressed) forControlEvents:UIControlEventTouchUpInside];
		[clear addTarget:_delegate action:@selector(btnClearPressed) forControlEvents:UIControlEventTouchUpInside];
		[routesManager addTarget:_delegate action:@selector(btnRoutesManagerPressed) forControlEvents:UIControlEventTouchUpInside];
		[searchRoute addTarget:_delegate action:@selector(btnSearchRoutePressed) forControlEvents:UIControlEventTouchUpInside];
		[home addTarget:_delegate action:@selector(btnHomePressed) forControlEvents:UIControlEventTouchUpInside];
		
    }
    return self;
}

- (void)layoutIfNeeded {
}
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

-(void)changeOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
		[bg setImage:[UIImage imageNamed:@"bg_search.png"]];
	else
		[bg setImage:[UIImage imageNamed:@"bg_search_landscape.png"]];
	
}
- (void)dealloc {
	[bg release];
    [super dealloc];
}


@end
