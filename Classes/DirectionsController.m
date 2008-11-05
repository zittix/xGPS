//
//  GeoEncoder.m
//  xGPS
//
//  Created by Mathieu on 9/22/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "DirectionsController.h"

#import "xGPSAppDelegate.h"


@implementation Instruction
@synthesize name;
@synthesize pos;
@synthesize descr;
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

+ (NSString *) urlencode: (NSString *) url encoding:(NSString*)enc
{
	CFStringEncoding cEnc= kCFStringEncodingUTF8;
	
	if([enc isEqualToString: @"latin1"] )
		cEnc=kCFStringEncodingISOLatin1;
	
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, CFSTR("?=&+"), cEnc);
	return [result autorelease];
	//return url;
}
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	instructions=[[NSMutableDictionary alloc] initWithCapacity:5];
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
	if([elementName isEqualToString:@"coordinates"] && ((parsingPlace==YES && currentPos==nil) || (parsingLinestring==YES))) {
		currentProp=[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"LineString"] && !parsingLinestring && parsingPlace==YES) {
		parsingLinestring=YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if([elementName isEqualToString:@"Placemark"]) {
		if( parsingPlace && currentPlacename!=nil && currentPos!=nil && !parsingLinestring) {
			NSArray *p_arr=[currentPos componentsSeparatedByString:@","];
			
			if([p_arr count]==3) {
				float lon=[[p_arr objectAtIndex:0] floatValue];
				float lat=[[p_arr objectAtIndex:1] floatValue];
				PositionObj *p=[PositionObj positionWithX:lat y:lon];
				
				if(currentDescr!=nil) {
					NSMutableString *tmp=(NSMutableString*)currentDescr;
					[tmp replaceOccurrencesOfString:@"<br/>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
				}
				
				Instruction *r=[Instruction instrWithName:currentPlacename pos:p descr:currentDescr];
				NSString *key=[NSString stringWithFormat:@"%d",[instructions count]];
				[instructions setObject:r forKey:key];
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
	if([elementName isEqualToString:@"coordinates"] && !parsingLinestring && parsingPlace==YES && currentPos==nil) {
		currentPos=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"coordinates"] && parsingLinestring && parsingPlace==YES) {
		[roadPoints removeAllObjects];
		
		NSArray *p_arr=[currentProp componentsSeparatedByString:@" "];
		for(NSString* prop in p_arr) {
			NSArray *p_arr2=[prop componentsSeparatedByString:@","];
			if([p_arr2 count]==3) {
				float lon=[[p_arr2 objectAtIndex:0] floatValue];
				float lat=[[p_arr2 objectAtIndex:1] floatValue];
				PositionObj *p=[PositionObj positionWithX:lat y:lon];

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
	//if(req==nil) return;
	//[delegate geoEncodeGot:[result autorelease] forRequest:[req autorelease] error:nil];
	instructions=nil;
	
	
	[currentPlacename release];
	currentPlacename=nil;
	
	[currentPos release];
	
	
	[currentProp release];
	
	[currentDescr release];
	currentDescr=nil;
	currentPos=nil;
	currentProp=nil;
	parsingPlace=NO;
	computing=NO;
	parsingLinestring=NO;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Parse error from delegate");
	//if(req==nil) return;
	
	//[delegate geoEncodeGot:result forRequest:req  error:nil];
	instructions=nil;
	
	
	[currentPlacename release];
	currentPlacename=nil;
	
	[currentPos release];
	
	[currentDescr release];
	currentDescr=nil;
	
	[currentProp release];
	
	currentPos=nil;
	currentProp=nil;
	parsingPlace=NO;
	computing=NO;
	parsingLinestring=NO;
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
	
	//[delegate geoEncodeGot:result forRequest:req  error:error];
	instructions=nil;
	
	[currentPlacename release];
	currentPlacename=nil;
	[currentPos release];
	[currentProp release];
	[currentDescr release];
	currentDescr=nil;
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
	
    // release the connection, and the data object
    [connection release];
    [resultData release];
}
-(BOOL)drive:(NSString*)from to:(NSString*)to {
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline]) return NO;
	
	if(computing) return NO;
	
	_from=[from retain];
	_to=[to retain];
	
	NSString *lang=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
	if(lang==nil) lang=@"en";
	NSLog(@"Using %@ language",lang);
	
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
		currentDescr=nil;
		parsingLinestring=NO;
		return YES;
	} else {
		// inform the user that the download could not be made
		return NO;
	}
	
}
@end
