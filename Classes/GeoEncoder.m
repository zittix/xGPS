//
//  GeoEncoder.m
//  xGPS
//
//  Created by Mathieu on 9/22/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "GeoEncoder.h"

#import "xGPSAppDelegate.h"


@implementation GeoEncoderResult
@synthesize name;
@synthesize pos;
@synthesize addr;

+(GeoEncoderResult*)resultWithName:(NSString*)name pos:(PositionObj*)pos addr:(NSString*)addr{
	GeoEncoderResult*r=[[GeoEncoderResult alloc] init];
	r.pos=pos;
	r.name=name;
	r.addr=addr;
	return [r autorelease];
}
@end



@implementation GeoEncoder
@synthesize delegate;
@synthesize location;

-(id) init {
	if((self=[super init])) {
		location=YES;
	}
	return self;
}

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
	result=[[NSMutableDictionary alloc] initWithCapacity:5];
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
	if([elementName isEqualToString:@"address"] && parsingPlace==YES && currentAddr==nil) {
		currentProp=[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"Snippet"] && parsingPlace==YES && currentAddr==nil) {
		currentProp=[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"coordinates"] && parsingPlace==YES && currentPos==nil) {
		currentProp=[[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if([elementName isEqualToString:@"Placemark"]) {
		if( parsingPlace && currentPlacename!=nil && currentPos!=nil) {
			NSArray *p_arr=[currentPos componentsSeparatedByString:@","];
			
			if([p_arr count]==3) {
				float lon=[[p_arr objectAtIndex:0] floatValue];
				float lat=[[p_arr objectAtIndex:1] floatValue];
				PositionObj *p=[PositionObj positionWithX:lat y:lon];
				
				if(currentAddr!=nil) {
					NSMutableString *tmp=(NSMutableString*)currentAddr;
					[tmp replaceOccurrencesOfString:@"<br/>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
				}
				
				GeoEncoderResult *r=[GeoEncoderResult resultWithName:currentPlacename pos:p addr:currentAddr];
				NSString *key=[NSString stringWithFormat:@"%d",[result count]];
				[result setObject:r forKey:key];
			}
		} else {
			NSLog(@"Invalid placemark");
		}
		if(currentPlacename!=nil)
			[currentPlacename release];
		currentPlacename=nil;
		if(currentPos!=nil)
			[currentPos release];
		if(currentAddr!=nil)
			[currentAddr release];
		currentAddr=nil;
		currentPos=nil;
		parsingPlace=NO;
		if(currentProp!=nil)
			[currentProp release];
		currentProp=nil;
	}
	if([elementName isEqualToString:@"name"] && parsingPlace==YES && currentPlacename==nil) {
		currentPlacename=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"address"] && parsingPlace==YES && currentAddr==nil) {
		//NSLog(@"Found Address");
		currentAddr=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"Snippet"] && parsingPlace==YES && currentAddr==nil) {
		//NSLog(@"Found Snippet");
		currentAddr=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"coordinates"] && parsingPlace==YES && currentPos==nil) {
		currentPos=currentProp;
		currentProp=nil;
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (currentProp!=nil) {
		[currentProp appendString:string];
    }
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"End geocode ok with %d results",[result count]);
	if(req==nil) return;
	[delegate geoEncodeGot:[result autorelease] forRequest:[req autorelease] error:nil];
	result=nil;
	req=nil;
	if(currentPlacename!=nil)
		[currentPlacename release];
	currentPlacename=nil;
	if(currentPos!=nil)
		[currentPos release];
	
	if(currentProp!=nil)
		[currentProp release];
	if(currentAddr!=nil)
		[currentAddr release];
	currentAddr=nil;
	currentPos=nil;
	currentProp=nil;
	parsingPlace=NO;
	retryingWithoutLoc=NO;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Parse error from delegate");
	if(req==nil) return;
	retryingWithoutLoc=NO;
	[delegate geoEncodeGot:result forRequest:[req autorelease]  error:nil];
	result=nil;
	req=nil;
	if(currentPlacename!=nil)
		[currentPlacename release];
	currentPlacename=nil;
	if(currentPos!=nil)
		[currentPos release];
	if(currentAddr!=nil)
		[currentAddr release];
	currentAddr=nil;
	if(currentProp!=nil)
		[currentProp release];
	
	currentPos=nil;
	currentProp=nil;
	parsingPlace=NO;
	
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
	
	if(req==nil) return;
	retryingWithoutLoc=NO;
	[delegate geoEncodeGot:result forRequest:req  error:error];
	result=nil;
	req=nil;
	if(currentPlacename!=nil)
		[currentPlacename release];
	currentPlacename=nil;
	if(currentPos!=nil)
		[currentPos release];
	
	if(currentProp!=nil)
		[currentProp release];
	if(currentAddr!=nil)
		[currentAddr release];
	currentAddr=nil;
	currentPos=nil;
	currentProp=nil;
	parsingPlace=NO;
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
    NSLog(@"Succeeded! Received %d bytes of data with redone=%d",[resultData length],retryingWithoutLoc);
	
	if([resultData length]==0) {
		[connection release];
		[resultData release];
		if(!retryingWithoutLoc && APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.mode>1) {
			retryingWithoutLoc=YES;
			[self geoencode:req];
			[req release];
			return;
		}
		retryingWithoutLoc=NO;
	} else {
		
		NSXMLParser *xmlParser=[[NSXMLParser alloc] initWithData:resultData];
		[xmlParser setShouldProcessNamespaces:NO];
		[xmlParser setShouldReportNamespacePrefixes:NO];
		[xmlParser setShouldResolveExternalEntities:NO];
		
		if(xmlParser==nil) {
			NSLog(@"Parsing error");
		} else {
			xmlParser.delegate=self;
			if(![xmlParser parse]) {
				NSLog(@"Parsing error 2");
			}
			//[dataR release];
			[xmlParser release];
		}
		[connection release];
		[resultData release];
		retryingWithoutLoc=NO;
	}
    // release the connection, and the data object
	
}
-(BOOL)geoencode:(NSString*)toEncode {
	//if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline]) return NO;
	if(req!=nil && !retryingWithoutLoc) return NO;
	
	
	
	NSString *lang=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
	if(lang==nil) lang=@"en";
	//NSLog(@"Using %@ language",lang);
	
	NSString *search=toEncode;
	
	//Add location if available
	if(APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.mode>1 && !retryingWithoutLoc && location) {
		search=[NSString stringWithFormat:@"%@ loc:%f,%f",search,APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.latitude,APPDELEGATE.gpsmanager.currentGPS.gps_data.fix.longitude];
	}
	
	NSString* encURL=[GeoEncoder urlencode:search encoding:@"utf8"];
	
	NSString *urlT=[NSString stringWithFormat:@"http://maps.google.com/maps?ie=UTF8&oe=UTF8&output=kml&q=%@&hl=%@",encURL,lang];
	//NSLog(@"Getting geoencode at %@",urlT);
	//
	NSURL *url = [NSURL URLWithString:urlT];
	
	//NSMutableURLRequest *urlReq=[NSMutableURLRequest requestWithURL:url];
	
	
	//[urlReq setValue:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1" forHTTPHeaderField:@"User-Agent"];
	//[urlReq setValue:@"image/png,image/*;q=0.8,*/*;q=0.5" forHTTPHeaderField:@"Accept"];
	//[urlReq setValue:@"http://maps.google.com/maps" forHTTPHeaderField:@"Referer"];
	
	// create the request
	NSURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
													 cachePolicy:NSURLRequestUseProtocolCachePolicy
												 timeoutInterval:30.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		resultData=[[NSMutableData data] retain];
		parsingPlace=NO;
		req=[toEncode retain];
		currentPlacename=nil;
		currentPos=nil;
		currentProp=nil;
		currentAddr=nil;
		return YES;
	} else {
		// inform the user that the download could not be made
		return NO;
	}
}
@end
