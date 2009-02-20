#import <UIKit/UIKit.h>

@interface ProgressView : UIView
{
	CGRect rect;
	UIProgressView* progressBar;
	float progressValue;
	UILabel* ltext;
	UILabel* prctext;
	UIButton *button;
	id currentDelegate;
}
- (void)dealloc;
-(void)setBtnSelector:(SEL)sel withDelegate:(id)del;
- (id)initWithFrame:(CGRect)frame;
- (void)setProgress:(float) progress;
- (void) setProgressObj: (NSNumber*) progress;
- (void)setStatusText:(NSString*)str;
- (void)showFrom:(UIView*)view;
- (void)hide;
-(void)hideCancelButton;
-(void)hideProgressText;
@property (nonatomic,readonly) UILabel *ltext;
@end