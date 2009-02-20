//
//  RoutesManagerViewController.m
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RoutesManagerViewController.h"
#import "xGPSAppDelegate.h"
#import "RouteCell.h"
#import "RouteAddViewController.h"
@implementation RoutesManagerViewController


-(id)initWithStyle:(UITableViewStyle)style delegate:(id<RoutesManagerDelegate>)_delegate {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.navigationItem.rightBarButtonItem=self.editButtonItem;		
		self.tableView.allowsSelectionDuringEditing=YES;  
		self.title=NSLocalizedString(@"Routes Manager",@"");
		self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",@"") style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
		[self.navigationItem.leftBarButtonItem release];
		delegate=_delegate;
	}
    return self;
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
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	 return YES;
 }
 
-(void)close {
	[self dismissModalViewControllerAnimated:YES];
	[delegate setEditingKeyBoard];
}
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
		return 1;
	else
		return 1+[bookmarks count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier=@"";
	
    if(indexPath.row<0 || (bookmarks!=nil && indexPath.row>[bookmarks count])) {
		return nil;
	}
	NSDictionary *dict;
	if(bookmarks!=nil && indexPath.row>0)
		dict=[bookmarks objectAtIndex:indexPath.row-1];
	
	if(bookmarks==nil || indexPath.row==0)
		CellIdentifier=@"addroute";
	else
		CellIdentifier=[NSString stringWithFormat:@"%d",[[dict valueForKey:@"id"] intValue]];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		switch(indexPath.row) {
			case 0: {
				 cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell.text=NSLocalizedString(@"Create a new route",@"");
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
				cell.image=[UIImage imageNamed:@"addicon.png"];
			}break;
			default: 
			if(bookmarks!=nil) {
				RouteCell *cell2= [[[RouteCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
				cell=cell2;
				cell2.lblFrom.text=[dict valueForKey:@"from"];
				cell2.lblTo.text=[dict valueForKey:@"to"];
				NSString *name=[dict valueForKey:@"name"];
				if(name==nil || name.length==0) name=NSLocalizedString(@"No name",@"");
				cell2.lblName.text=name;
			}break;
				
		}
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	int row=indexPath.row;
	if(row>0 && row<=[bookmarks count]) {
		NSDictionary *dict=[bookmarks objectAtIndex:row-1];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	int row=indexPath.row;
    if(row>0 && row<=[bookmarks count]) {
		NSDictionary *dict=[bookmarks objectAtIndex:row-1];
		int id=[[dict valueForKey:@"id"] intValue];
		NSMutableArray *road=[APPDELEGATE.dirbookmarks copyBookmarkRoadPoints:id];
		NSMutableArray *instr=[APPDELEGATE.dirbookmarks copyBookmarkInstructions:id];
		[APPDELEGATE.directions clearResult];
		[APPDELEGATE.directions setFrom:[dict valueForKey:@"from"]];
		[APPDELEGATE.directions setTo:[dict valueForKey:@"to"]];
		[APPDELEGATE.directions setRoad:road instructions:instr];
		[APPDELEGATE.directions setRoad:road instructions:instr];
		APPDELEGATE.directions.currentBookId=id;
		
		[road release];
		[instr release];
		[self.navigationController dismissModalViewControllerAnimated:YES];
	} else if (row==0) {
		UINavigationController *nav=[[RouteAddViewController alloc] init];
		[self.navigationController pushViewController:nav animated:YES];
		[nav release];
	}
	
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return indexPath.row>0 ? YES : NO;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row>0 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


- (void)dealloc {
	[bookmarks release];
    [super dealloc];
}


@end

