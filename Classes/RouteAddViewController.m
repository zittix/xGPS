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
#import "xGPSAppDelegate.h"

@implementation RouteAddViewController

@synthesize tableView;
- (void)loadView {
	self.view=[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[self.view release];
	
	tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,125,self.view.frame.size.width,self.view.frame.size.height-125) style:UITableViewStylePlain];
	tableView.dataSource=self;
	tableView.delegate=self;
	tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.title=NSLocalizedString(@"New Route",@"");
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
	[self.navigationItem.rightBarButtonItem release];
	points=[[NSMutableArray alloc] initWithCapacity:3];
	self.tableView.allowsSelectionDuringEditing=YES;
	editingRow=-1;
	[self clearAll];
	UIView* viewButton=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,125)];
	UIButton* btnCompute=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnCompute setTitle:NSLocalizedString(@"Compute",@"")  forState:UIControlStateNormal];
	
	UIButton* btnClear=[UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnClear setTitle:NSLocalizedString(@"Clear All",@"")  forState:UIControlStateNormal];
	viewButton.backgroundColor=[UIColor whiteColor];
	btnClear.frame=CGRectMake(5,5,(self.view.frame.size.width-15)/2.0,35);
	btnCompute.frame=CGRectMake(5+(self.view.frame.size.width-15)/2.0+5,5,(self.view.frame.size.width-15)/2.0,35);
	btnCompute.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
	btnClear.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	[btnClear addTarget:self action:@selector(clearAll) forControlEvents:UIControlEventTouchUpInside];
	[btnCompute addTarget:self action:@selector(compute) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *lblDescr=[[UILabel alloc] initWithFrame:CGRectMake(5,90,60,30)];
	lblDescr.text=NSLocalizedString(@"Name:",@"");
	lblDescr.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
	lblDescr.adjustsFontSizeToFitWidth=YES;
	[viewButton addSubview:lblDescr];
	[lblDescr release];
	
	txtName=[[UITextField alloc] initWithFrame:CGRectMake(70,90,self.view.frame.size.width-75,30)];
	txtName.borderStyle=UITextBorderStyleBezel;
	txtName.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
	txtName.delegate=self;
	[viewButton addSubview:txtName];
	//NSLocalizedString(@"No Higway",@"")
	NSArray *items=[NSArray arrayWithObjects:NSLocalizedString(@"By Car",@""),NSLocalizedString(@"Walking",@""),nil];
	routeType=[[UISegmentedControl alloc] initWithItems:items];
	routeType.frame=CGRectMake(5,45,self.view.frame.size.width-10,40);
	routeType.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	routeType.selectedSegmentIndex=0;
	[viewButton addSubview:btnClear];
	[viewButton addSubview:btnCompute];
	[viewButton addSubview:routeType];
	viewButton.autoresizesSubviews=YES;

	viewButton.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	
	//self.tableView.tableHeaderView=viewButton;
	[self.view addSubview:viewButton];
	[self.view addSubview:tableView];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
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
	NavigationPoint *p_start=[points objectAtIndex:0];
	NavigationPoint *p_end=[points objectAtIndex:points.count-1];
	if((p_start.pos.x==0 && p_start.pos.y==0) || (p_end.pos.x==0 && p_end.pos.y==0)) {
		UIAlertView * hotSheet = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"Route computation",@"")
								  message:NSLocalizedString(@"You have to add at lest one starting and one ending point in your route.",@"")
								  delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss")
								  otherButtonTitles:nil];
		
		[hotSheet show];	
		return;
	}
	if(points.count>10) {
		UIAlertView * hotSheet = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"Route computation",@"")
								  message:[NSString stringWithFormat:NSLocalizedString(@"You cannot have more than %d points in your route.",@""),10]
								  delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss")
								  otherButtonTitles:nil];
		
		[hotSheet show];	
		return;
	}
	if(txtName.text.length==0) {
		UIAlertView * hotSheet = [[UIAlertView alloc]
								  initWithTitle:NSLocalizedString(@"Route computation",@"")
								  message:[NSString stringWithFormat:NSLocalizedString(@"Please enter a name for your route.",@""),10]
								  delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss")
								  otherButtonTitles:nil];
		
		[hotSheet show];	
		[txtName becomeFirstResponder];
		return;
	}
	[txtName resignFirstResponder];
	NSString *from=p_start.pos.description;
	NSString *to=p_end.pos.description;
	NSMutableArray * arr=nil;
	if(points.count - 2>0)
	arr=[NSMutableArray arrayWithCapacity:points.count -2];
	
	pController=[[ProgressViewController alloc] init];

	[pController.progress hideCancelButton];
	pController.progress.ltext.text=NSLocalizedString(@"Computing your route...",@"");
	[pController.progress setBtnSelector:@selector(cancelRoute) withDelegate:self];
	[pController.progress setProgress:0.2];
	[APPDELEGATE.directions clearResult];
	APPDELEGATE.directions.recomputing=YES;
	switch(routeType.selectedSegmentIndex) {
		case 0:
			APPDELEGATE.directions.routingType=ROUTING_NORMAL;
			break;
		case 1:
			APPDELEGATE.directions.routingType=ROUTING_BY_FOOT;
			break;
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	if(![APPDELEGATE.directions drive:from to:to via:arr delegate:self]) {
		APPDELEGATE.directions.routingType=ROUTING_NORMAL;
		APPDELEGATE.directions.recomputing=NO;
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:[NSString stringWithFormat:NSLocalizedString(@"Unable to retrieve the required information from the server: %@",@"Network error message"),NSLocalizedString(@"Unknown error",@"Unknown error")] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[alert show];
		[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
		return;
	};
	

	[self presentModalViewController:pController animated:NO];
	
}
-(void)cancelRoute {
	
}

-(void)directionsGot:(NSString*)from to:(NSString*)to error:(NSError*)err {
	[self dismissModalViewControllerAnimated:NO];
	[pController release];
	pController=nil;
	if(err==nil) {
		
		//Search the first instruction
		if([APPDELEGATE.directions.instructions count]>0) {
			//Save and pop
			[APPDELEGATE.directions saveCurrent:txtName.text];
			[APPDELEGATE.directions clearResult];
			
			//NSLog(@"Done...");
			
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"No driving direction can be computed using your query.",@"No driving dir. found error message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
			[alert show];
		}
	}
	else {
		UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:[NSString stringWithFormat:NSLocalizedString(@"Unable to retrieve the driving directions from the server: %@",@"Network error message"),[err localizedDescription]] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
		[alert show];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
	APPDELEGATE.directions.routingType=ROUTING_NORMAL;
	APPDELEGATE.directions.recomputing=NO;

}
-(void)nextDirectionChanged:(Instruction*)instr {
	
}
-(void)nextDirectionDistanceChanged:(double)dist {
	
}
-(void)showWrongWay {
	
}
-(void)hideWrongWay {
	
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex==2) return;
	
	ModalSearchViewController *manager=[[ModalSearchViewController alloc] initWithDelegate:self];
	
	
	[self presentModalViewController:manager animated:YES];
	
	switch(buttonIndex) {
		case 1:
			manager.location=NO;
			break;
		case 0:
			manager.location=YES;
			break;
	}
	
	
	[manager release];
	
}
-(void)add {
	[txtName resignFirstResponder];
	UIActionSheet *action=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Add / Modify:",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Location / Place",@""),NSLocalizedString(@"Address",@""),nil];
	[action showInView:self.view];

	
	}
-(void) searchPlaceWillHide {
	editingRow=-1;
	[self dismissModalViewControllerAnimated:YES];
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
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"%d",indexPath.row];
	if(indexPath.row>=points.count || indexPath.row<0) return [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	// NSLog(@"Getting %d cell",indexPath.row);
	
    NavigationPoint *point=[points objectAtIndex:indexPath.row];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
	editingRow=-1;
	[p release];
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
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
		//NSLog(@"removeObjectAtIndex %d",row);
		[points removeObjectAtIndex:row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];	
	}
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	//NSLog(@"Getting moive %d",toIndexPath.row);
	//NSLog(@"Getting moive %d",fromIndexPath.row);
	if(fromIndexPath.row>=points.count || toIndexPath.row>=points.count) return;
	NavigationPoint *p=[[points objectAtIndex:fromIndexPath.row] retain];
	NavigationPoint *p2=[[points objectAtIndex:toIndexPath.row] retain];
	[points replaceObjectAtIndex:fromIndexPath.row withObject:p2];
	[points replaceObjectAtIndex:toIndexPath.row withObject:p];
	[p release];
	[p2 release];
	//NSLog(@"%@",points);
	//[self updatePicture];
	//[self.tableView reloadData];
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.4];
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

