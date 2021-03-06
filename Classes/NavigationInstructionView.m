//
//  NavigationInstructionView.m
//  xGPS
//
//  Created by Mathieu on 11/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "NavigationInstructionView.h"
#import "xGPSAppDelegate.h"

@implementation NavigationInstructionView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		//132 152 179
		self.backgroundColor=[UIColor colorWithRed:0.51764705f green:0.5960784314f blue:0.7019607843 alpha:1];
		lbl=[[UILabel alloc] initWithFrame:CGRectMake(10,0,frame.size.width-20,frame.size.height)];
		[self addSubview:lbl];
		lbl.textAlignment=UITextAlignmentCenter;
		lbl.backgroundColor=[UIColor clearColor];
		lbl.textColor=[UIColor whiteColor];
		lbl.font=[UIFont boldSystemFontOfSize:16];
		lbl.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		lbl.numberOfLines=0;
		lbl.lineBreakMode=UILineBreakModeWordWrap;
		lbl.shadowColor=[UIColor blackColor];
		[self fontChanged];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}
#define HORIZ_SWIPE_DRAG_MIN  70
#define VERT_SWIPE_DRAG_MAX    4
-(void)setTextSize:(float)size {
	lbl.font=[UIFont boldSystemFontOfSize:size];
}
-(void)fontChanged {
	BOOL stat=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsLargeFont];
	if(stat)
		lbl.font=[UIFont boldSystemFontOfSize:22];
	else
		lbl.font=[UIFont boldSystemFontOfSize:16];
	[self sizeToFit];
}
-(void)setNightMode:(BOOL)val {
	[UIView beginAnimations:nil context:nil];
	if(val)
	self.backgroundColor=[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1];
	else
		self.backgroundColor=[UIColor colorWithRed:0.51764705f green:0.5960784314f blue:0.7019607843 alpha:1];
	[UIView commitAnimations];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    startTouchPosition = [touch locationInView:self];
	swipeDir=0;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
		if(swipeDir==1)
			[delegate nextDrivingInstructions];
		else if(swipeDir==-1)
			[delegate previousDrivingInstructions];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self];
	
    // If the swipe tracks correctly.
    if (fabsf(startTouchPosition.x - currentTouchPosition.x) >= HORIZ_SWIPE_DRAG_MIN &&
        fabsf(startTouchPosition.y - currentTouchPosition.y) <= VERT_SWIPE_DRAG_MAX)
    {
        // It appears to be a swipe.
        if (startTouchPosition.x < currentTouchPosition.x)
			swipeDir=-1;
        else
            swipeDir=1;
    }
   
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.width-=20;
	CGSize lblSize=[lbl sizeThatFits:size];
	lblSize.width=self.frame.size.width;
	lblSize.height=MAX(lblSize.height,30);
	return lblSize;
}
-(void)setText:(NSString*)txt {
	[lbl setText:txt];
}
- (void)dealloc {
	[super dealloc];
	[lbl release];
}


@end
