//
//  GoogleDirectionsRetriever.m
//  xGPS
//
//  Created by Mathieu on 08.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GoogleDirectionsRetriever.h"
#import "xGPSAppDelegate.h"
#import "NavigationPoint.h"
@implementation GoogleDirectionsRetriever

#pragma mark XMLParser

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
	[delegate directionsGot:instructions roads:roadPoints from:_from to:_to via:_via error:nil];
	[self clean];

	
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
	retrieving=NO;
	parsingLinestring=NO;
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Parse error from delegate");
	//if(req==nil) return;
	
	[delegate directionsGot:nil roads:nil from:_from to:_to via:_via error:[parseError localizedDescription]];

	//instructions=nil;
	
	
	[currentPlacename release];
	currentPlacename=nil;
	
	[currentPos release];
	
	[currentDescr release];
	currentDescr=nil;

	[currentProp release];
	
	currentPos=nil;
	currentProp=nil;
	parsingPlace=NO;
	startAddr=nil;
	stopAddr=nil;
	retrieving=NO;
	parsingLinestring=NO;
}
#pragma mark AsyncURLLoader

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
	
	[delegate directionsGot:nil roads:nil from:_from to:_to via:_via error:[error localizedDescription]];
	
	
	
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
	retrieving=NO;
	parsingLinestring=NO;
	[self clean];
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
			retrieving=NO;
			NSLog(@"Parsing error");
			[self clean];
		} else {
			xmlParser.delegate=self;
			if(![xmlParser parse]) {
				retrieving=NO;
				NSLog(@"Parsing error 2");
				[self clean];
			}
			[xmlParser release];
		}
	} else {
		retrieving=NO;
		[delegate directionsGot:nil roads:nil from:_from to:_to via:_via error:nil];
		
		delegate=nil;
		[self clean];
	}
    // release the connection, and the data object
    [connection release];
    [resultData release];
}
-(void)clean {
	[_from release];
	[_to release];
	[_via release];
	_from=nil;
	_to=nil;
	_via=nil;
	[instructions release];
	[roadPoints release];
	instructions=roadPoints=nil;
}

-(BOOL)getDirections:(NSString*)from to:(NSString*)to via:(NSArray*)via delegate:(id<DirectionsRetrieverProtocol>)_tmpDelegate routing:(RoutingType)routingType{
	
	//if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline]) return NO;
	delegate=_tmpDelegate;
	if(retrieving) return NO;
	
	retrieving=YES;
	_via=[via retain];
	_from=[from retain];
	_to=[to retain];
	NSString *lang=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
	if(lang==nil) lang=@"en";
	
	NSString* fromE=[DirectionsController urlencode:from encoding:@"utf8"];
	NSString* toE=[DirectionsController urlencode:to encoding:@"utf8"];
	NSString *advTo=toE;
	
	
	
	if(via!=nil) {
		advTo=@"";
		for(NavigationPoint *p in via) {
			if(advTo.length==0) 
				advTo=[advTo stringByAppendingFormat:@"%f,%f",p.pos.x,p.pos.y];
			else
				advTo=[advTo stringByAppendingFormat:@"+to:%f,%f",p.pos.x,p.pos.y];
		}
		
		
		
		advTo=[advTo stringByAppendingFormat:@"+to:%@",toE];
	}
	
	
	NSString *unit;
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsSpeedUnit])
		unit=@"ptm";
	else
		unit=@"ptk";
	
	NSString *routeType=@"";
	switch(routingType) {
		case ROUTING_NORMAL:
			if([lang isEqualToString:@"ja"])
				routeType=@"&dirflg=d";
			break;
		case ROUTING_AVOID_HIGHWAY:
			if([lang isEqualToString:@"ja"])
				routeType=@"&dirflg=dh";
			else
				routeType=@"&dirflg=h";
			break;
		case ROUTING_BY_FOOT:
			if([lang isEqualToString:@"ja"])
				routeType=@"&dirflg=dt";
			else
				routeType=@"&dirflg=w";
			break;
	}	
	
	NSString *urlT=[NSString stringWithFormat:@"http://maps.google.com/maps?ie=UTF8&oe=UTF8&output=kml&hl=%@&saddr=%@&daddr=%@&doflg=%@%@",lang,fromE,advTo,unit,routeType];
	
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
@end
