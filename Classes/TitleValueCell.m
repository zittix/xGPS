//
//  TitleValueCell.m
//  xGPS
//
//  Created by Mathieu on 27.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TitleValueCell.h"


@implementation TitleValueCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		titlelbl=[[UILabel alloc] initWithFrame:CGRectMake(10,5,(self.frame.size.width-25)/2.0,(self.frame.size.height-10))];
		//titlelbl.adjustsFontSizeToFitWidth=YES;
		titlelbl.font = [UIFont boldSystemFontOfSize:16.0];
		titlelbl.textAlignment = UITextAlignmentLeft;
		titlelbl.backgroundColor=[UIColor clearColor];
		titlelbl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
		
		valuelbl=[[UILabel alloc] initWithFrame:CGRectMake(10+(self.frame.size.width-25)/2.0+5,5,(self.frame.size.width-25)/2.0,(self.frame.size.height-10))];
		valuelbl.adjustsFontSizeToFitWidth=YES;
		valuelbl.font = [UIFont systemFontOfSize:16.0];
		valuelbl.textAlignment = UITextAlignmentRight;
		valuelbl.backgroundColor=[UIColor clearColor];
		valuelbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
		
		valuelbl.textColor=[UIColor colorWithRed:0.235 green:0.2549 blue:0.49019 alpha:1];
		self.selectionStyle=UITableViewCellSelectionStyleNone;
		[self.contentView addSubview:titlelbl];
		[self.contentView addSubview:valuelbl];
    }
    return self;
}
/*
- (CGSize)sizeThatFits:(CGSize)size {
	//size.width-=20;
	//CGSize lblSize=[lbl sizeThatFits:size];
	//lblSize.width=self.frame.size.width;
	//lblSize.height=MAX(lblSize.height,30);
	//return lblSize;
}*/


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
	[titlelbl release];
	[valuelbl release];
}
-(void)setTitle:(NSString*)t {
	titlelbl.text=t;
	CGSize size=[titlelbl sizeThatFits:CGSizeMake(3*(self.frame.size.width-25)/4.0+20,self.frame.size.height-10)];
	size.height=self.frame.size.height-10;
	titlelbl.frame=CGRectMake(10, 5, size.width+20, size.height);
	valuelbl.frame=CGRectMake(10+titlelbl.frame.size.width+5,5,self.frame.size.width-titlelbl.frame.size.width-25,(self.frame.size.height-10));
}
-(void)setValue:(NSString*)v {
	valuelbl.text=v;
}
-(NSString*)value {
	return valuelbl.text;
}
-(NSString*)title {
	return titlelbl.text;
}
@end
