//
//  NavigationInstructionView.m
//  xGPS
//
//  Created by Mathieu on 11/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "NavigationInstructionView.h"


@implementation NavigationInstructionView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		//132 152 179
		self.backgroundColor=[UIColor colorWithRed:0.51764705f green:0.5960784314f blue:0.7019607843 alpha:0.8];
		lbl=[[UILabel alloc] initWithFrame:CGRectMake(10,0,frame.size.width-20,frame.size.height)];
		[self addSubview:lbl];
		lbl.textAlignment=UITextAlignmentCenter;
		lbl.backgroundColor=[UIColor clearColor];
		lbl.textColor=[UIColor whiteColor];
		lbl.font=[UIFont boldSystemFontOfSize:14];
		lbl.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		lbl.numberOfLines=0;
		lbl.shadowColor=[UIColor blackColor];
		
    }
    return self;
}
#define HORIZ_SWIPE_DRAG_MIN  70
#define VERT_SWIPE_DRAG_MAX    4

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
	
	[UIView beginAnimations:nil context:nil];
	[lbl setText:txt];
	[self sizeToFit];
	[UIView commitAnimations];
}
- (void)dealloc {
	[lbl release];
    [super dealloc];
}


@end
