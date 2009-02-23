//
//  RouteCell.m
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteCell.h"


@implementation RouteCell
@synthesize lblFrom;
@synthesize lblName;
@synthesize lblTo;
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		frame=self.frame;
		lblName=[[UILabel alloc] initWithFrame:CGRectMake(5,5,frame.size.width-10,20)];
		[self addSubview:lblName];
		lblName.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		lblName.adjustsFontSizeToFitWidth=YES;
		lblName.font=[UIFont boldSystemFontOfSize:14];
		
		
		UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(5,25,50,20)];
		lbl.text=NSLocalizedString(@"From:",@"");
		lbl.textColor=[UIColor blueColor];
		lbl.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:lbl];
		[lbl release];
		
		lblFrom=[[UILabel alloc] initWithFrame:CGRectMake(65,25,frame.size.width-65,20)];
		[self addSubview:lblFrom];
		lblFrom.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		lblFrom.adjustsFontSizeToFitWidth=YES;

		
		lbl=[[UILabel alloc] initWithFrame:CGRectMake(5,45,50,20)];
		lbl.text=NSLocalizedString(@"To:",@"");
		[self addSubview:lbl];
		lbl.textColor=[UIColor blueColor];
		lbl.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
		[lbl release];
		
		lblTo=[[UILabel alloc] initWithFrame:CGRectMake(65,45,frame.size.width-65,20)];
		
		[self addSubview:lblTo];
		lblTo.autoresizingMask=UIViewAutoresizingFlexibleWidth;
		lblTo.adjustsFontSizeToFitWidth=YES;
		self.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)dealloc {
	[lblFrom release];
	[lblTo release];
	[lblName release];
    [super dealloc];
}


@end
