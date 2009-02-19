//
//  RouteAddViewController.m
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteAddViewController.h"
#import "NavigationPoint.h"
#import "ModalSearchViewController.h"
@implementation RouteAddViewController


- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		self.title=NSLocalizedString(@"New Route",@"");
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
		[self.navigationItem.rightBarButtonItem release];
		points=[[NSMutableArray alloc] initWithCapacity:3];
			self.tableView.allowsSelectionDuringEditing=YES;
		editingRow=-1;
		[self clearAll];
		UIView* viewButton=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,45)];
		UIButton* btnCompute=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		[btnCompute setTitle:NSLocalizedString(@"Compute",@"")  forState:UIControlStateNormal];
		
		UIButton* btnClear=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		[btnClear setTitle:NSLocalizedString(@"Clear All",@"")  forState:UIControlStateNormal];
		
		btnClear.frame=CGRectMake(5,5,(self.view.frame.size.width-15)/2.0,35);
		btnCompute.frame=CGRectMake(5+(self.view.frame.size.width-15)/2.0+5,5,(self.view.frame.size.width-15)/2.0,35);
		[btnClear addTarget:self action:@selector(clearAll) forControlEvents:UIControlEventTouchUpInside];
		[btnCompute addTarget:self action:@selector(compute) forControlEvents:UIControlEventTouchUpInside];
		[viewButton addSubview:btnClear];
		[viewButton addSubview:btnCompute];
		self.tableView.tableHeaderView=viewButton;
    }
    return self;
}

-(void)clearAll {
	[points removeAllObjects];
	NavigationPoint *p=[[NavigationPoint alloc] init];
	p.name=NSLocalizedString(@"Tap to edit",@"");
	[points addObject:p];
	[p release];
	p=[[NavigationPoint alloc] init];
	p.name=NSLocalizedString(@"Tap to edit",@"");
	[points addObject:p];
	[p release];
	[self.tableView reloadData];
}
-(void)compute {
	
}
-(void)add {
	UIViewController *manager=[[ModalSearchViewController alloc] initWithDelegate:self];

	[self presentModalViewController:manager animated:YES];
	[manager release];
}
-(void) searchPlaceWillHide {
	
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
	
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView setEditing:YES animated:YES];
}

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
    return points.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d",indexPath.row];
    NavigationPoint *point=[points objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		
		
    }
	if(indexPath.row==0) {
		cell.image=[UIImage imageNamed:@"startway.png"];
	}
	else if(indexPath.row==points.count -1) {
		cell.image=[UIImage imageNamed:@"endway.png"];
	} else {
		cell.image=[UIImage imageNamed:@"middleway.png"];
	}
	
	cell.text=point.name;
	
    return cell;
}
-(void)gotResultForSearch:(GeoEncoderResult*)res {
	NavigationPoint *p=[[NavigationPoint alloc] init];
	p.name=res.name;
	p.pos=res.pos;
	if(editingRow<0) {
	NavigationPoint *p_start=[points objectAtIndex:0];
	NavigationPoint *p_end=[points objectAtIndex:points.count-1];
	if(p_start.pos.x==0 && p_start.pos.y==0) {
		[points removeObjectAtIndex:0];
		[points insertObject:p atIndex:0];
	} else if(p_end.pos.x==0 && p_end.pos.y==0) {
		[points removeObjectAtIndex:points.count-1];
		[points addObject:p];
	} else
		[points addObject:p];
	} else {
		[points replaceObjectAtIndex:editingRow withObject:p];
	}
	[p release];
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	editingRow=indexPath.row;
	[self add];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	int row=indexPath.row;
	if(row>0 && row<[points count]-1) {
		[points removeObjectAtIndex:row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];	
	}
}

-(void)updatePicture {
	for(int i=0;i<points.count;i++) {
		NSString *CellIdentifier = [NSString stringWithFormat:@"%d",i];
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if(i==0) {
			cell.image=[UIImage imageNamed:@"startway.png"];
		}
		else if(i==points.count -1) {
			cell.image=[UIImage imageNamed:@"endway.png"];
		} else {
			cell.image=[UIImage imageNamed:@"middleway.png"];
		}
	}	
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	NavigationPoint *p=[[points objectAtIndex:fromIndexPath.row] retain];
	NavigationPoint *p2=[[points objectAtIndex:toIndexPath.row] retain];
	[points replaceObjectAtIndex:fromIndexPath.row withObject:p2];
	[points replaceObjectAtIndex:toIndexPath.row withObject:p];
	[p release];
	[p2 release];
	//[self updatePicture];
	//[self.tableView reloadData];
}




// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row>0 && indexPath.row<points.count-1 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)dealloc {
	[points release];
    [super dealloc];
}


@end

