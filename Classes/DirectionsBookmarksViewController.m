//
//  DirectionsBookmarksViewController.m
//  xGPS
//
//  Created by Mathieu on 25.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DirectionsBookmarksViewController.h"
#import "xGPSAppDelegate.h"

@implementation DirectionsBookmarksViewController


-(id)initWithStyle:(UITableViewStyle)style delegate:(id)_delegate {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		delegate=_delegate;
		self.title=NSLocalizedString(@"Bookmarks",@"");
		UIBarButtonItem *btn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hide)];
		self.navigationItem.leftBarButtonItem=btn;
		[btn release];
		btn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
		self.navigationItem.rightBarButtonItem=btn;
		[btn release];
    }
    return self;
}
-(void)hide {
	[self.navigationController dismissModalViewControllerAnimated:YES];
	[delegate setEditingKeyBoard];
}
-(void)edit {
	
	if(self.tableView.editing==NO) {
		UIBarButtonItem *btn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(edit)];
		[self.tableView setEditing:YES animated:YES];
		//[UIView beginAnimations:nil context:nil];
		self.navigationItem.rightBarButtonItem=btn;
		[btn release];
		//[UIView commitAnimations];
	} else {
		UIBarButtonItem *btn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
		[self.tableView setEditing:NO animated:YES];
		//[UIView beginAnimations:nil context:nil];
		self.navigationItem.rightBarButtonItem=btn;
		[btn release];
		//[UIView commitAnimations];
	}
}
/*
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 */


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[bookmarks release];
	bookmarks=[APPDELEGATE.dirbookmarks copyBookmarks];
	[self.tableView reloadData];
}

/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if(self.tableView.editing) {
		UIBarButtonItem *btn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
		[self.tableView setEditing:NO animated:YES];
		//[UIView beginAnimations:nil context:nil];
		self.navigationItem.rightBarButtonItem=btn;
		[btn release];
		//[UIView commitAnimations];
	}
}

/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(bookmarks==nil)
		return 0;
	else
		return [bookmarks count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d",indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		int row=indexPath.row;
		if(row>=0 && row<[bookmarks count]) {
			NSDictionary *dict=[bookmarks objectAtIndex:row];
			UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(5,5,50,20)];
			lbl.text=NSLocalizedString(@"From:",@"");
			lbl.textColor=[UIColor blueColor];
			lbl.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
			[cell.contentView addSubview:lbl];
			[lbl release];
			
			lbl=[[UILabel alloc] initWithFrame:CGRectMake(65,5,self.tableView.frame.size.width-65,20)];
			lbl.text=[dict valueForKey:@"from"];
			[cell.contentView addSubview:lbl];
			lbl.autoresizingMask=UIViewAutoresizingFlexibleWidth;
			lbl.adjustsFontSizeToFitWidth=YES;
			[lbl release];
			
			lbl=[[UILabel alloc] initWithFrame:CGRectMake(5,25,50,20)];
			lbl.text=NSLocalizedString(@"To:",@"");
			[cell.contentView addSubview:lbl];
			lbl.textColor=[UIColor blueColor];
			lbl.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
			[lbl release];
			
			lbl=[[UILabel alloc] initWithFrame:CGRectMake(65,25,self.tableView.frame.size.width-65,20)];
			lbl.text=[dict valueForKey:@"to"];
			[cell.contentView addSubview:lbl];
			lbl.autoresizingMask=UIViewAutoresizingFlexibleWidth;
			lbl.adjustsFontSizeToFitWidth=YES;
			[lbl release];
		}
    }
    
    // Set up the cell...
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row=indexPath.row;
	if(row>=0 && row<[bookmarks count]) {
		NSDictionary *dict=[bookmarks objectAtIndex:row];
		int id=[[dict valueForKey:@"id"] intValue];
		NSMutableArray *road=[APPDELEGATE.dirbookmarks copyBookmarkRoadPoints:id];
		NSMutableArray *instr=[APPDELEGATE.dirbookmarks copyBookmarkInstructions:id];
		[APPDELEGATE.directions setRoad:road instructions:instr];
		[road release];
		[instr release];
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	int row=indexPath.row;
	if(row>=0 && row<[bookmarks count]) {
		NSDictionary *dict=[bookmarks objectAtIndex:row];
		if(dict!=nil) {
			long id=[[dict valueForKey:@"id"] longValue];
			if(id>=0) {
				[APPDELEGATE.dirbookmarks deleteBookmark:id];
				[((NSMutableArray*)bookmarks) removeObject:dict];
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
				
			}
		}
	}
}


- (void)dealloc {
	[bookmarks release];
    [super dealloc];
}


@end

