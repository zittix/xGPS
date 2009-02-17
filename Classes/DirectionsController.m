//
//  GeoEncoder.m
//  xGPS
//
//  Created by Mathieu on 9/22/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "DirectionsController.h"

#import "xGPSAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "MapView.h"
#import "MainViewController.h"

int roundNearest(double dist) {
	//We dont want 13 but 10, we dont want 345 but 340
	double dist2=dist/10;
	int dist3=dist2;
	return dist3*10;
}

@implementation Instruction
@synthesize name;
@synthesize pos;
@synthesize descr;
@synthesize dist;

+(Instruction*)instrWithName:(NSString*)name pos:(PositionObj*)pos descr:(NSString*)descr {
	Instruction*r=[[Instruction alloc] init];
	r.pos=pos;
	r.name=name;
	r.descr=descr;
	return [r autorelease];
}
-(void)dealloc {
	[pos release];
	[name release];
	[descr release];
	[super dealloc];
}
@end



@implementation DirectionsController
@synthesize delegate;
@synthesize roadPoints;
@synthesize instructions;
@synthesize currentBookId;
#define DEG_TO_RAD (M_PI/180.0f)
/// @brief Earth's quatratic mean radius for WGS-84
#define EARTH_RADIUS_IN_METERS 6372797.560856

+ (NSString *) urlencode: (NSString *) url encoding:(NSString*)enc
{
	CFStringEncoding cEnc= kCFStringEncodingUTF8;
	
	if([enc isEqualToString: @"latin1"] )
		cEnc=kCFStringEncodingISOLatin1;
	
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, CFSTR("?=&+"), cEnc);
	return [result autorelease];
	//return url;
}
-(void)recomputeChanged:(NSNotification *)notif {
	recomputeRoute=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsRecomputeDriving];
	enableVoice=[[NSUserDefaults standardUserDefaults] boolForKey:kSettingsEnableVoiceInstr];
}
-(id)init {
	if((self=[super init])) {
		pos=[[PositionObj alloc] init];
		[self recomputeChanged:nil];
		beforeThreshold=100;
		farThreshold=500;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recomputeChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
		currentBookId=-1;
	}
	return self;
}
-(void)dealloc {
	[super dealloc];
	[pos release];
}
/*
 
 Subject 1.02: How do I find the distance from a point to a line?
 
 
 Let the point be C (Cx,Cy) and the line be AB (Ax,Ay) to (Bx,By).
 Let P be the point of perpendicular projection of C on AB.  The parameter
 r, which indicates P's position along AB, is computed by the dot product 
 of AC and AB divided by the square of the length of AB:
 
 (1)    AC dot AB
 r = ---------  
 ||AB||^2
 
 r has the following meaning:
 
 r=0      P = A
 r=1      P = B
 r<0      P is on the backward extension of AB
 r>1      P is on the forward extension of AB
 0<r<1    P is interior to AB
 
 The length of a line segment in d dimensions, AB is computed by:
 
 L = sqrt( (Bx-Ax)^2 + (By-Ay)^2 + ... + (Bd-Ad)^2)
 
 so in 2D:  
 
 L = sqrt( (Bx-Ax)^2 + (By-Ay)^2 )
 
 and the dot product of two vectors in d dimensions, U dot V is computed:
 
 D = (Ux * Vx) + (Uy * Vy) + ... + (Ud * Vd)
 
 so in 2D:  
 
 D = (Ux * Vx) + (Uy * Vy) 
 
 So (1) expands to:
 
 (Cx-Ax)(Bx-Ax) + (Cy-Ay)(By-Ay)
 r = -------------------------------
 L^2
 
 The point P can then be found:
 
 Px = Ax + r(Bx-Ax)
 Py = Ay + r(By-Ay)
 
 And the distance from A to P = r*L.
 
 Use another parameter s to indicate the location along PC, with the 
 following meaning:
 s<0      C is left of AB
 s>0      C is right of AB
 s=0      C is on AB
 
 Compute s as follows:
 
 (Ay-Cy)(Bx-Ax)-(Ax-Cx)(By-Ay)
 s = -----------------------------
 L^2
 
 
 Then the distance from C to P = |s|*L.
 
 */
-(double)distanceBetween:(PositionObj*)p and:(PositionObj*)p2 {
	double latitudeArc  = (p.x - p2.x) * DEG_TO_RAD;
	double longitudeArc = (p.y - p2.y) * DEG_TO_RAD;
    double latitudeH = sin(latitudeArc * 0.5);
    latitudeH *= latitudeH;
    double lontitudeH = sin(longitudeArc * 0.5);
    lontitudeH *= lontitudeH;
    double tmp = cos(p.x*DEG_TO_RAD) * cos(p2.x*DEG_TO_RAD);
    return EARTH_RADIUS_IN_METERS * 2.0 * asin(sqrt(latitudeH + tmp*lontitudeH));	
}
-(void)updatePos:(PositionObj*)p {
	pos.x=p.x;
	pos.y=p.y;
	//NSLog(@"DIr update pos");
	//Check the next directions
	
	if(instructions==nil || [instructions count]<1 || [roadPoints count]<2 || computing) return;
	
	
	//We work in 4 phases
	/*
	 1. Find the road step where the position belong to
	 2. Project the position onto the road to get the remaining distance to do on this road step
	 3. Compute the length of each further road steps until the next instruction
	 4. Update display
	 */
	
	/*1,2*/
	//In order to accept a road step as the one where we are, we must be at +-8 meters of the road step
	
	//We compute: 
	/*
	 (1)    AC dot AB
	 r = ---------  
	 ||AB||^2
	 for each segement and take the one where 0<r<1 where AB is the road and C the GPS pos
	 */
	PositionObj *road1=nil;
	CLLocation *c_p=[[CLLocation alloc] initWithLatitude:p.x longitude:p.y];
	CLLocation *c_p2=[[CLLocation alloc] init];
	CLLocation *c_b=[[CLLocation alloc] init];
	PositionObj *road2=nil;
	CGPoint c;
	int cx,cy;
	int offyc,offxc;
	[MapView getXYfrom:p.x andLon:p.y toPositionX:&cx andY:&cy withZoom:0];
	[MapView getXYOffsetfrom:p.x andLon:p.y toPositionX:&offxc andY:&offyc withZoom:0];
	c.x=cx+offxc/256.0;
	c.y=cy+offyc/256.0;
	double remainingDist=0;
	PositionObj *groad1=nil;
	PositionObj *groad2=nil;
	int i;
	//int counterIterRoad=0;
	//int counterIterInstr=0;
	for(int j=0;j<2;j++) {
		//double minDist=-1;
		//int found=-1;
		
		if(previousSegement>=0)
			i=previousSegement;
		else
			i=0;
		for(i;i<[roadPoints count];i++) {
			if(i>=[roadPoints count]-1) continue;
			road1=[roadPoints objectAtIndex:i];
			road2=[roadPoints objectAtIndex:i+1];
			//counterIterRoad++;
			//Convert to mercator (cartersian)
			int ax,ay,bx,by;
			int offxa,offxb,offya,offyb;
			[MapView getXYfrom:road1.x andLon:road1.y toPositionX:&ax andY:&ay withZoom:0];
			[MapView getXYfrom:road2.x andLon:road2.y toPositionX:&bx andY:&by withZoom:0];
			[MapView getXYOffsetfrom:road1.x andLon:road1.y toPositionX:&offxa andY:&offya withZoom:0];
			[MapView getXYOffsetfrom:road2.x andLon:road2.y toPositionX:&offxb andY:&offyb withZoom:0];
			
			CGPoint a,b;
			a.x=ax+offxa/256.0;
			a.y=ay+offya/256.0;
			b.x=bx+offxb/256.0;
			b.y=by+offyb/256.0;
			
			double r_numerator=(c.x-a.x)*(b.x-a.x)+(c.y-a.y)*(b.y-a.y);
			double r_denomenator=pow((b.y-a.y),2)+pow((b.x-a.x),2);
			double r = r_numerator / (r_denomenator);
			if(r>0 && r<1) {
				//
				double px = a.x + r*(b.x-a.x);
				double py = a.y + r*(b.y-a.y);
				
				
				//Compute the distance between (px,py)=p2 and p => must be +- 8 meters
				double p2lat,p2lon;
				int to_x=(int)px;
				int to_y=(int)py;
				int to_offx=(int)((px-to_x)*256.0);
				int to_offy=(int)((py-to_y)*256.0);
				[MapView getLatLonfromXY:to_x andY:to_y withXOffset:to_offx andYOffset:to_offy toLat:&p2lat andLon:&p2lon withZoom:0];
				c_p2=[c_p2 initWithLatitude:p2lat longitude:p2lon];
				
				//double dist=[self distanceBetween:p and:p2];
				
				double dist=fabs([c_p getDistanceFrom:c_p2]);
				
				if(dist<=15) {
					//NSLog(@"Found road segments at %f m with r=%f",dist,r);
					c_b=[c_b initWithLatitude:road2.x longitude:road2.y];
					//Projection
					remainingDist=fabs([c_b getDistanceFrom:c_p2]);
					//NSLog(@"Remaining dist %f",remainingDist);
					//minDist=dist;
					//found=i;
					groad1=road1;
					groad2=road2;
					break;
				} else {
					//NSLog(@"Found !!!!bad road segments at %f m",dist);
					road1=nil;
					road2=nil;
				}
				
				
			}else {
				road1=nil;
				road2=nil;
			}
		}
		if((groad1==nil || groad2==nil) && previousSegement>=0) {
			previousSegement=-1;
			//NSLog(@"Second pas!!!!!!!!!!!!!!!!!");
		} else
			break;
	}
	[c_p2 release];
	[c_p release];
	
	if(groad1==nil || groad2==nil) {
		//If we have not found were we are, check if we are near a point defining road
		road1=[roadPoints objectAtIndex:0];
		
		double tmp=[self distanceBetween:road1 and:p];
		if(tmp<=20.0) {
			i=-1;
			road2=[roadPoints objectAtIndex:1];
			groad1=road1;
			groad2=road2;
			remainingDist=fabs([self distanceBetween:road1 and:road2]);
		}
	}
	
	
	if(groad1==nil || groad2==nil) {
		
		if(nbWrongWay>5*APPDELEGATE.gpsmanager.currentGPS.refreshRate){
			if(previousInstruction==[instructions count]-1) {
				
				[delegate hideWrongWay];
			} else if(![[NSUserDefaults standardUserDefaults] boolForKey:kSettingsWrongWayHidden]) {
				[delegate showWrongWay];
			}
			if(previousInstruction!=[instructions count]-1) {
				if(nbWrongWay>20*APPDELEGATE.gpsmanager.currentGPS.refreshRate && recomputeRoute) {
					[self recompute];
				} else {
					nbWrongWay++;
				}
			}
		} else {
			nbWrongWay++;
		}
		[c_b release];
		return;
	}
	
	nbWrongWay=0;
	[delegate hideWrongWay];
	
	//map.debugRoadStep=i+2;
	[map refreshMap];
	previousSegement=i;
	
	/*3*/
	Instruction *next=nil;
	double distNext=-1;
	
	for(i=i+1;i<[roadPoints count];i++) {
		for(int k=0;k<2;k++) {
			int j;
			if(previousInstruction>=0)
				j=previousInstruction;
			else
				j=0;
			for(j;j<[instructions count];j++) {
				//counterIterInstr++;
				Instruction *instr=[instructions objectAtIndex:j];
				double dist=fabs([self distanceBetween:[roadPoints objectAtIndex:i] and:instr.pos]);
				
				
				if(dist>=0 && dist<=2 && previousInstruction-1<=j && previousInstruction+1!=[instructions count]){ // Allow to step back from one instruction when we get the false direction
					distNext=dist;
					next=instr;
					previousInstruction=j;
					break;
				} 
			}
			if(next==nil && previousInstruction>=0) {
				previousInstruction=-1;
			} else
				break;	
		}
		if(i+1<[roadPoints count])
			remainingDist+=fabs([self distanceBetween:[roadPoints objectAtIndex:i] and:[roadPoints objectAtIndex:i+1]]);	
		
		
		if(next!=nil) break;
	}
	//NSLog(@"Done %d pas for road and %d for instr",counterIterRoad,counterIterInstr);
	
	if(next!=nil ) {
		if(inBetweenDistance<0) inBetweenDistance=remainingDist;
		if(instrIndex!=previousInstruction) {
			instrIndex=previousInstruction;
			next.dist=remainingDist;
			[delegate nextDirectionChanged:next];
			[map setNextInstruction:next updatePos:NO];
			playedSoundFarmeters=NO;
			playedSoundBeforemeters=NO;
			inBetweenDistance=remainingDist;
		}
		if(enableVoice) {
			float beforeThresholdCalc=beforeThreshold;
			float farThresholdCalc=farThreshold;
			double speed=APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.speed*3.6;
			if(speed<30) speed=30;
			if(speed>120) speed=120;
			
			beforeThresholdCalc=speed*(beforeThreshold/30.0)+speed*1.944444f; //The + is for the playing time of the audio mean=6s (7/3.6=1.94444)
			farThresholdCalc=speed*(farThreshold/30.0);
			
			//NSLog(@"Threshold before: %f, far: %f",beforeThresholdCalc,farThresholdCalc);
			
			if(!playedSoundBeforemeters && remainingDist<=beforeThresholdCalc && instrIndex>0) {
				playedSoundFarmeters=YES;
				playedSoundBeforemeters=YES;
				SoundEvent *s=[[SoundEvent alloc] initWithText:[NSString stringWithFormat:@"In %d meters, %@",roundNearest(remainingDist),next.name] andSound:Sound_Announce];
				[APPDELEGATE.soundcontroller addSound:s];
				[s release];
				
			} else if(!playedSoundFarmeters && remainingDist<=farThresholdCalc && inBetweenDistance>farThresholdCalc && instrIndex>0) {
				playedSoundFarmeters=YES;
				SoundEvent *s=[[SoundEvent alloc] initWithText:[NSString stringWithFormat:@"In %d meters, %@",roundNearest(remainingDist),next.name] andSound:Sound_Announce];
				[APPDELEGATE.soundcontroller addSound:s];
				[s release];
			}
		}
		[delegate nextDirectionDistanceChanged:remainingDist];
	}
	[c_b release];
	
}
-(void)recompute {
	float lat=APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.latitude;
	float lon=APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.longitude;
	
	NSString*from=[[NSString alloc] initWithFormat:@"%f,%f",lat,lon];
	NSString *to=[_to retain];
	[delegate clearDirections];
	recomputing=YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	[self drive:from to:to];
	[from release];
	[to release];
}
-(void)nextDrivingInstructions {
	if(instructions==nil) return;
	if([instructions count]>0 && instrIndex<[instructions count]-1) {
		instrIndex++;
		Instruction *s=[instructions objectAtIndex:instrIndex];
		[delegate nextDirectionChanged:s];
		[map setNextInstruction:s updatePos:YES];
	}
}
-(void)previousDrivingInstructions {
	if(instructions==nil) return;
	if([instructions count]>0 && instrIndex>0) {
		instrIndex--;
		Instruction *s=[instructions objectAtIndex:instrIndex];
		[delegate nextDirectionChanged:s];
		[map setNextInstruction:s updatePos:YES];
	}
}
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	instructions=[[NSMutableArray alloc] initWithCapacity:5];
	roadPoints=[[NSMutableArray alloc] initWithCapacity:5];
	NSLog(@"Parser start...");
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	//NSLog(@"Found start element %@",elementName);
	if([elementName isEqualToString:@"Placemark"] && parsingPlace==NO) {
		parsingPlace=YES;
	}
	if([elementName isEqualToString:@"name"] && parsingPlace==YES && currentPlacename==nil) {
		currentProp=[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"description"] && parsingPlace==YES && currentDescr==nil) {
		currentProp=[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"address"] && parsingPlace==YES && (startAddr==nil || stopAddr==nil)) {
		currentProp=[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"coordinates"] && ((parsingPlace==YES && currentPos==nil) || (parsingLinestring==YES))) {
		currentProp=[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"LineString"] && !parsingLinestring && parsingPlace==YES) {
		parsingLinestring=YES;
	}
}
-(void)htmlToChar:(NSMutableString*)s {
	for(int i=32;i<=127;i++) {
		[s replaceOccurrencesOfString:[NSString stringWithFormat:@"&#%d;",i] withString:[NSString stringWithFormat:@"%c",(char)i] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	}
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if([elementName isEqualToString:@"Placemark"]) {
		if( parsingPlace && currentPlacename!=nil && currentPos!=nil && !parsingLinestring) {
			NSArray *p_arr=[currentPos componentsSeparatedByString:@","];
			
			if([p_arr count]==3) {
				double lon=[[p_arr objectAtIndex:0] doubleValue];
				double lat=[[p_arr objectAtIndex:1] doubleValue];
				PositionObj *p=[PositionObj positionWithX:lat y:lon];
				
				if(currentDescr!=nil) {
					NSMutableString *tmp=(NSMutableString*)currentDescr;
					[tmp replaceOccurrencesOfString:@"<br/>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
					[self htmlToChar:tmp];
				}
				if(currentPlacename!=nil) {
					NSMutableString *tmp=(NSMutableString*)currentPlacename;
					[tmp replaceOccurrencesOfString:@"  " withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
					[self htmlToChar:tmp];
				}
				
				//Filter out html encoded characters
				
				
				Instruction *r=[Instruction instrWithName:currentPlacename pos:p descr:currentDescr];
				
				[instructions addObject:r];
			}
		} else if(parsingLinestring) {
			
		} else {
			NSLog(@"Invalid placemark");
		}
		[currentPlacename release];
		currentPlacename=nil;
		[currentPos release];
		
		[currentDescr release];
		currentDescr=nil;
		currentPos=nil;
		parsingPlace=NO;
		parsingLinestring=NO;
		[currentProp release];
		currentProp=nil;
	}
	if([elementName isEqualToString:@"name"] && parsingPlace==YES && currentPlacename==nil) {
		currentPlacename=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"description"] && parsingPlace==YES && currentDescr==nil) {
		currentDescr=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"address"] && parsingPlace==YES && startAddr==nil) {
		startAddr=currentProp;
		currentProp=nil;
	} else if([elementName isEqualToString:@"address"] && parsingPlace==YES && stopAddr==nil) {
		stopAddr=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"coordinates"] && !parsingLinestring && parsingPlace==YES && currentPos==nil) {
		currentPos=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"coordinates"] && parsingLinestring && parsingPlace==YES) {
		//[roadPoints removeAllObjects];
		
		NSArray *p_arr=[currentProp componentsSeparatedByString:@" "];
		for(NSString* prop in p_arr) {
			NSArray *p_arr2=[prop componentsSeparatedByString:@","];
			if([p_arr2 count]==3) {
				double lon=[[p_arr2 objectAtIndex:0] doubleValue];
				double lat=[[p_arr2 objectAtIndex:1] doubleValue];
				PositionObj *p=[PositionObj positionWithX:lat y:lon];
				//NSLog(@"Point %f %f",lat,lon);
				[roadPoints addObject:p];
			}
		}
		
		[currentProp release];
		currentProp=nil;
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (currentProp!=nil) {
		[currentProp appendString:string];
    }
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"End directions ok with %d instructions and %d road points",[instructions count],[roadPoints count]);
	
	if(startAddr!=nil) {
		[_from release];
		_from=startAddr;
	}
	if(stopAddr!=nil) {
		[_to release];
		_to=stopAddr;
	}
	
	nbWrongWay=0;
	inBetweenDistance=-1;
	[delegate directionsGot:_from to:_to  error:nil];
	if([instructions count]>0){
		
		if(!recomputing && [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSaveDirSearch])
		currentBookId=[APPDELEGATE.dirbookmarks insertBookmark:roadPoints withInstructions:instructions from:_from to:_to];
		
		
		Instruction *s=[instructions objectAtIndex:instrIndex];
		[delegate nextDirectionChanged:s];
		[map setNextInstruction:s updatePos:YES];
	}
	
	recomputing=NO;
	
	//if(req==nil) return;
	
	//instructions=nil;
	previousSegement=previousInstruction=-1;
	
	[currentPlacename release];
	currentPlacename=nil;
	
	[currentPos release];
	
	
	[currentProp release];
	
	[currentDescr release];
	currentDescr=nil;
	currentPos=nil;
	startAddr=nil;
	stopAddr=nil;
	currentProp=nil;
	parsingPlace=NO;
	computing=NO;
	parsingLinestring=NO;
		
}
-(void)setRoad:(NSMutableArray*)road instructions:(NSMutableArray*)instr {
	[instructions release];
	instructions=[instr retain];
	[roadPoints release];
	roadPoints=[road retain];
	[map setNextInstruction:nil updatePos:NO];
	nbWrongWay=0;
	instrIndex=0;
	[delegate directionsGot:_from to:_to  error:nil];
	if([instructions count]>0){
		Instruction *s=[instructions objectAtIndex:instrIndex];
		[map setNextInstruction:s updatePos:YES];
		[delegate nextDirectionChanged:s];
	}
}


-(void)clearResult {
	[instructions release];
	instructions=nil;
	[roadPoints release];
	roadPoints=nil;
	[_from release];
	[_to release];
	_from=nil;
	_to=nil;
	currentBookId=-1;
	startAddr=nil;
	stopAddr=nil;
	[map setNextInstruction:nil updatePos:NO];
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Parse error from delegate");
	//if(req==nil) return;
	
	[delegate directionsGot:_from to:_to  error:parseError];
	//instructions=nil;
	
	
	[currentPlacename release];
	currentPlacename=nil;
	
	[currentPos release];
	
	[currentDescr release];
	currentDescr=nil;
	recomputing=NO;
	[currentProp release];
	
	currentPos=nil;
	currentProp=nil;
	parsingPlace=NO;
	startAddr=nil;
	stopAddr=nil;
	computing=NO;
	parsingLinestring=NO;
}
-(NSString*) from {
	return _from;
}
-(NSString*) to {
	return _to;
}
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [resultData release];
	resultData=nil;
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	//if(req==nil) return;
	
	[delegate directionsGot:_from to:_to  error:error];
	
	instructions=nil;
	
	[currentPlacename release];
	currentPlacename=nil;
	[currentPos release];
	[currentProp release];
	[currentDescr release];
	currentDescr=nil;
	startAddr=nil;
	stopAddr=nil;
	currentPos=nil;
	currentProp=nil;
	parsingPlace=NO;
	computing=NO;
	parsingLinestring=NO;
}	
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [resultData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [resultData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[resultData length]);
	if([resultData length]>0) {
		NSXMLParser *xmlParser=[[NSXMLParser alloc] initWithData:resultData];
		[xmlParser setShouldProcessNamespaces:NO];
		[xmlParser setShouldReportNamespacePrefixes:NO];
		[xmlParser setShouldResolveExternalEntities:NO];
		
		if(xmlParser==nil) {
			computing=NO;
			NSLog(@"Parsing error");
		} else {
			xmlParser.delegate=self;
			if(![xmlParser parse]) {
				computing=NO;
				NSLog(@"Parsing error 2");
			}
			[xmlParser release];
		}
	} else {
		computing=NO;
		recomputing=NO;
		[delegate directionsGot:_from to:_to  error:nil];
	}
    // release the connection, and the data object
    [connection release];
    [resultData release];
}
-(BOOL)drive:(NSString*)from to:(NSString*)to {
	//if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline]) return NO;
	
	if(computing) return NO;
	
	_from=[from retain];
	_to=[to retain];
	instrIndex=0;
	NSString *lang=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
	if(lang==nil) lang=@"en";
	//NSLog(@"Using %@ language",lang);
	
	NSString* fromE=[DirectionsController urlencode:from encoding:@"utf8"];
	NSString* toE=[DirectionsController urlencode:to encoding:@"utf8"];
	
	NSString *unit;
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit])
		unit=@"ptm";
	else
		unit=@"ptk";
	
	
	NSString *urlT=[NSString stringWithFormat:@"http://maps.google.com/maps?ie=UTF8&oe=UTF8&output=kml&hl=%@&saddr=%@&daddr=%@&doflg=%@",lang,fromE,toE,unit];
	
	NSLog(@"Getting directions at %@",urlT);
	
	NSURL *url = [NSURL URLWithString:urlT];
	
	
	// create the request
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:30.0];
	
	[theRequest setValue:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1" forHTTPHeaderField:@"User-Agent"];
	[theRequest setValue:@"http://maps.google.com/maps" forHTTPHeaderField:@"Referer"];
	
	
	
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		resultData=[[NSMutableData data] retain];
		parsingPlace=NO;
		//req=[toEncode retain];
		currentPlacename=nil;
		currentPos=nil;
		currentProp=nil;
		startAddr=nil;
		stopAddr=nil;
		currentDescr=nil;
		parsingLinestring=NO;
		return YES;
	} else {
		// inform the user that the download could not be made
		return NO;
	}
	
}
-(PositionObj*)pos {
	return pos;
}
-(void)setFrom:(NSString*)f {
	[_from release];
	_from=[f retain];
}
-(void)setTo:(NSString*)f {
	[_to release];
	_to=[f retain];
}
@synthesize map;

@end
