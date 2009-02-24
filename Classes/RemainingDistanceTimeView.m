//
//  RemainingDistanceTimeView.m
//  xGPS
//
//  Created by Mathieu on 11/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "RemainingDistanceTimeView.h"
#import "xGPSAppDelegate.h"

@implementation RemainingDistanceTimeView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		self.backgroundColor=[UIColor colorWithRed:0.51764705f green:0.5960784314f blue:0.7019607843 alpha:0.8];
		
		UIImageView *arrow=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_direction.png"]];
		arrow.frame=CGRectMake(5,5,19,19);
		[self addSubview:arrow];
		[arrow release];
		
		lblDist=[[UILabel alloc] initWithFrame:CGRectMake(29,0,frame.size.width-34,30)];
		[self addSubview:lblDist];
		lblDist.textAlignment=UITextAlignmentCenter;
		lblDist.backgroundColor=[UIColor clearColor];
		lblDist.textColor=[UIColor whiteColor];
		lblDist.font=[UIFont boldSystemFontOfSize:20];
		lblDist.adjustsFontSizeToFitWidth=YES;
		lblDist.text=@"N/A";
		
		UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0,27,frame.size.width,1)];
		line.backgroundColor=[UIColor whiteColor];
		[self addSubview:line];
		[line release];
		
		UILabel *lblTotal=[[UILabel alloc] initWithFrame:CGRectMake(0,31,frame.size.width,10)];
		[self addSubview:lblTotal];
		lblTotal.textAlignment=UITextAlignmentCenter;
		lblTotal.backgroundColor=[UIColor clearColor];
		lblTotal.textColor=[UIColor whiteColor];
		lblTotal.font=[UIFont boldSystemFontOfSize:14];
		lblTotal.text=NSLocalizedString(@"Total",@"");
		[lblTotal release];
		
		lblTotalDist=[[UILabel alloc] initWithFrame:CGRectMake(0,37,frame.size.width,frame.size.height-45)];
		[self addSubview:lblTotalDist];
		lblTotalDist.textAlignment=UITextAlignmentCenter;
		lblTotalDist.backgroundColor=[UIColor clearColor];
		lblTotalDist.textColor=[UIColor whiteColor];
		lblTotalDist.font=[UIFont systemFontOfSize:14];
		lblTotalDist.adjustsFontSizeToFitWidth=YES;
		lblTotalDist.text=@"N/A";
		totalDist=dist=-1;
		miles=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

-(void)setNightMode:(BOOL)val {
	[UIView beginAnimations:nil context:nil];
	if(val)
		self.backgroundColor=[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1];
	else
		self.backgroundColor=[UIColor colorWithRed:0.51764705f green:0.5960784314f blue:0.7019607843 alpha:1];
	[UIView commitAnimations];
}

-(void) update:(UILabel*)lbl {
	
	double distToConvert=lbl==lblDist ? dist : totalDist;
	
	if(distToConvert<0){
		lbl.text=@"N/A";
		return;
	}
	double distConverted;	
	BOOL bigDistance=NO;
	if(miles)  {
		distConverted=distToConvert*3.2808399;
		bigDistance=NO;
		if(distConverted>500)
		{
			bigDistance=YES;
			distConverted=distToConvert*0.000621371192;
		}
		
	} else {
		distConverted=distToConvert;
		
		if(distConverted>500)
		{
			bigDistance=YES;
			distConverted=distToConvert/1000.0;
		}
	}
	
	if(miles)  {
		if(bigDistance)
			lbl.text=[NSString stringWithFormat:@"%.1f miles",distConverted];
		else
			lbl.text=[NSString stringWithFormat:@"%.0f feet",distConverted];
	} else {
		if(bigDistance)
			lbl.text=[NSString stringWithFormat:@"%.1f km",distConverted];
		else
			lbl.text=[NSString stringWithFormat:@"%.0f m",distConverted];
	}
	
}

-(void)unitChanged:(NSNotification *)notif {
	miles=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit];
	[self update:lblDist];
	[self update:lblTotalDist];
}
-(void)setDistance:(double)d {
	dist=d;
	[self update:lblDist];
}
-(void)setTime:(int)sec {
	
}
-(void)setTotalDistance:(double)d {
	totalDist=d;
	[self update:lblTotalDist];
}
- (void)dealloc {
	[lblDist release];
	[lblTotalDist release];
    [super dealloc];
}


@end
