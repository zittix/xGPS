#import <UIKit/UIKit.h>

#import "ProgressView.h"

@implementation ProgressView
- (id)initWithFrame:(struct CGRect)frame {
	rect=frame;

	self = [super initWithFrame:rect];
	if(self == nil) {
		return nil;
	}

	float translucentBlack[4] = {0, 0, 0, .8};
	self.autoresizesSubviews=YES;

	[self setBackgroundColor: [UIColor colorWithCGColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(), translucentBlack)]];

	ltext = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, 220.0f, rect.size.width, 30.0f)];
	prctext = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, 250.0f, rect.size.width, 30.0f)];
	ltext.textAlignment=UITextAlignmentCenter;
	ltext.backgroundColor=[UIColor colorWithWhite:0 alpha:0];
	ltext.text=NSLocalizedString(@"Downloading maps...",@"Downloading maps title view");
	prctext.text=[NSString stringWithFormat:@"0.0 %%"];
	prctext.textAlignment=UITextAlignmentCenter;
	prctext.backgroundColor=[UIColor colorWithWhite:0 alpha:0];

	[ltext setTextColor:[UIColor whiteColor]];
	ltext.font=[UIFont systemFontOfSize:16];
	[ltext setOpaque: YES];
	[self addSubview: ltext];

	[prctext setTextColor:[UIColor whiteColor]];
	ltext.font=[UIFont systemFontOfSize:16];
	[prctext setOpaque: YES];
	[self addSubview: prctext];

	// initialize the progress bar
	struct CGRect irect = CGRectMake((frame.size.width-200)/2, 200.0f, 200.0f, 25.0f);
	progressBar = [[UIProgressView alloc] initWithFrame: irect];
	progressBar.progress=0;

	[self addSubview: progressBar];

	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setTitle:NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
	button.frame=CGRectMake((frame.size.width-100)/2,300,100,50);
	[self addSubview: button];
	currentDelegate=nil;
	return self;
}
- (void)dealloc {
	[ progressBar release ];
	[ ltext release ];
	[ prctext release ];
	[ button release ];
	[ super dealloc ];
}
-(void)hideCancelButton  {
	[button removeFromSuperview];
}
-(void)hideProgressText {
	[prctext removeFromSuperview];
}

-(void)setBtnSelector:(SEL)sel withDelegate:(id)del {
	if(currentDelegate!=nil) {
		[button removeTarget:del action:sel forControlEvents:UIControlEventTouchUpInside];
	}
	[button addTarget:del action:sel forControlEvents:UIControlEventTouchUpInside];
	currentDelegate=del;
}
-(void)setStatusText:(NSString*)str {
	ltext.text=str;
}
- (void) fadeInFrom: (UIView*) view {
	[self setAlpha: 0.0f];
	[view addSubview: self];
	[UIView beginAnimations: nil context:nil];
	[UIView setAnimationDuration: 0.5f];
	[self setAlpha: 1.0f];
	[UIView commitAnimations];

}

- (void) fadeOut {
	[UIView beginAnimations: nil context:nil];
	[UIView setAnimationDuration: 0.5f];
	[self setAlpha: 0];
	[UIView commitAnimations];
	[self removeFromSuperview];
}
-(void)showFrom:(UIView*)view {
	[self fadeInFrom:view];
}
- (void) setProgressObj: (NSNumber*) progress {
	if([progress floatValue] <= 1) {
		[progressBar setProgress: [progress floatValue]];
	} else {
		[progressBar setProgress: 1];
	}
	NSString* prompt = [NSString stringWithFormat:@"%.1f %%",[progress floatValue]*100.0f];
	prctext.text=prompt;
}
- (void) setProgress: (float) progress {
	if(progress <= 1) {
		[progressBar setProgress: progress];
	} else {
		[progressBar setProgress: 1];
	}
	NSString* prompt = [NSString stringWithFormat:@"%.1f %%",progress*100.0f];
	prctext.text=prompt;
}
-(void)hide {
	[self fadeOut];
}
@end