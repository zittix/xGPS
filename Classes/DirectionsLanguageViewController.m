//
//  DirectionsLanguageViewController.m
//  xGPS
//
//  Created by Mathieu on 9/23/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "DirectionsLanguageViewController.h"
#import "xGPSAppDelegate.h"
#import "SettingsViewController.h"
@implementation DirectionsLanguageViewController

// Implement loadView to create a view hierarchy programmatically.
-(id)initWithFrame:(CGRect)f andController:(UITableViewController*)cnt {
	_cnt=cnt;
	if(([super initWithFrame:f])) {

	self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	self.autoresizesSubviews=YES;

	self.backgroundColor=[UIColor clearColor];
	self.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
	self.autoresizesSubviews=YES;
	picker=[[UIPickerView alloc] initWithFrame:CGRectMake(0,44.0f,f.size.width,f.size.height-44.0f)];
	picker.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	picker.delegate=self;
	picker.dataSource=self;
		picker.showsSelectionIndicator=YES;
	toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0,0,f.size.width,44.0f)];
	UIBarButtonItem *resizer=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *btnOK=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Dismiss",@"Dismiss") style:UIBarButtonItemStyleBordered target:self action:@selector(dismissView)];
	[toolbar setItems:[NSArray arrayWithObjects:resizer,btnOK,nil] animated:NO];
	toolbar.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	[btnOK release];
	[resizer release];
	[self addSubview:toolbar];
	[self addSubview:picker];
	
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
	[picker release];
	[toolbar release];
}

-(void)dismissView {
	[self removeFromSuperview];
	[(SettingsViewController*)_cnt setEnabled:YES];	
}
-(void)didMoveToSuperview {
	int row=0;
	NSString *lang=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
	if(lang!=nil) {
			if([lang isEqualToString:@"fr"])
				row=2;
			else if([lang isEqualToString:@"de"])
				row=1;
			else if([lang isEqualToString:@"it"])
				row=3;
			else if([lang isEqualToString:@"iw"])
				row=4;
	}
	
	[picker selectRow:row inComponent:0 animated:YES];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	switch(row) {
		case 0: return @"English";
		case 2: return @"Français";
		case 1: return @"Deutsch";
		case 3: return @"Italiano";
		case 4: return @"עברית";
		/*case 5: return @"繁體中文";*/
	}
	return @"Invalid";
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 5;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	switch(row) {
		case 0: [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:kSettingsMapsLanguage]; break;
		case 2: [[NSUserDefaults standardUserDefaults] setObject:@"fr" forKey:kSettingsMapsLanguage]; break;
		case 1: [[NSUserDefaults standardUserDefaults] setObject:@"de" forKey:kSettingsMapsLanguage]; break;
		case 3: [[NSUserDefaults standardUserDefaults] setObject:@"it" forKey:kSettingsMapsLanguage]; break;
		case 4: [[NSUserDefaults standardUserDefaults] setObject:@"iw" forKey:kSettingsMapsLanguage]; break;
		/*case 5: [[NSUserDefaults standardUserDefaults] setObject:@"zh" forKey:kSettingsMapsLanguage]; break;*/
	}
}


@end
