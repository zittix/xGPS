//
//  GPSSignalView.m
//  xGPS
//
//  Created by Mathieu on 9/26/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "GPSSignalView.h"


@implementation GPSSignalView


- (id)initWithFrame:(CGRect)frame delegate:(id<ShowGPSDetailProtocol>)_delegate {
    if ((self = [super initWithFrame:CGRectMake(frame.origin.x,frame.origin.y,45,54)])) {
        // Initialization code
		delegate=_delegate;
		//39x36
		red=[[UIImage imageNamed:@"rm_reception_none.png"] retain];
		green=[[UIImage imageNamed:@"rm_reception_good.png"] retain];
		orange=[[UIImage imageNamed:@"rm_reception_poor.png"] retain];
		grey=[[UIImage imageNamed:@"rm_reception_na.png"] retain];
		[self setBackgroundColor:[UIColor clearColor]];
		gps=[[UILabel alloc] initWithFrame:CGRectMake(0,36,self.frame.size.width,18)];
		gps.font=[UIFont fontWithName:@"Helvetica" size:14];
		gps.textAlignment=UITextAlignmentCenter;
		gps.minimumFontSize=10;
		gps.text=NSLocalizedString(@"N/A",@"Not available");
		gps.adjustsFontSizeToFitWidth=YES;
		gps.backgroundColor=[UIColor clearColor];
		gps.textColor=[UIColor darkGrayColor];
		quality=-1;
		[self addSubview:gps];
    }
    return self;
}
-(void)setFrame:(CGRect)frame {
	[super setFrame:CGRectMake(frame.origin.x,frame.origin.y,39,54)];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	//CGContextRef context=UIGraphicsGetCurrentContext();
	//CGContextSetShadow(context, CGSizeMake(2,-2), 2);
	
	if(quality<0) {
		[grey drawAtPoint:CGPointMake(0,0)];
		gps.text=NSLocalizedString(@"N/A",@"Not available");
	}else if(quality<33 && quality>=0){
		[red drawAtPoint:CGPointMake(0,0)];
		gps.text=NSLocalizedString(@"None",@"GPS Signal");
	}else if(quality >=33 && quality < 66){
		[orange drawAtPoint:CGPointMake(0,0)];
		gps.text=NSLocalizedString(@"Poor",@"GPS Signal");
	}else{
		[green drawAtPoint:CGPointMake(0,0)];
		gps.text=NSLocalizedString(@"Good",@"GPS Signal");
	}
	[super drawRect:rect];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet *t = [event touchesForView:self];
	if([t count]==1) {
		[delegate showGPSDetails];
	}
}
-(void)setQuality:(int)q {
	quality=q;
	[self setNeedsDisplay];
}
- (void)dealloc {
	[red release];
	[orange release];
	[green release];
	[gps release];
    [super dealloc];
}


@end
