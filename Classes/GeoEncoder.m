//
//  GeoEncoder.m
//  xGPS
//
//  Created by Mathieu on 9/22/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "GeoEncoder.h"

#import "xGPSAppDelegate.h"
#import "Position.h"
@implementation GeoEncoder
@synthesize delegate;

+ (NSString *) urlencode: (NSString *) url encoding:(NSString*)enc
{
	CFStringEncoding cEnc= kCFStringEncodingUTF8;
	
	if([enc isEqualToString: @"latin1"] )
		cEnc=kCFStringEncodingISOLatin1;
	
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, NULL, CFSTR("?=&+"), cEnc);
	return result;
	//return url;
}
- (void)parserDidStartDocument:(NSXMLParser *)parser {
	result=[[NSMutableDictionary alloc] initWithCapacity:5];
	NSLog(@"Parser start...");
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	NSLog(@"Found start element %@",elementName);
	if([elementName isEqualToString:@"Placemark"] && parsingPlace==NO) {
		parsingPlace=YES;
	}
	if([elementName isEqualToString:@"name"] && parsingPlace==YES && currentPlacename==nil) {
		currentProp=[[NSString alloc] init];
	}
	if([elementName isEqualToString:@"coordinates"] && parsingPlace==YES && currentPos==nil) {
		currentProp=[[NSString alloc] init];
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
				[result setObject:p forKey:currentPlacename];
			}
		} else {
			NSLog(@"Invalid placemark");
		}
		//if(currentPlacename!=nil)
		//	[currentPlacename release];
		currentPlacename=nil;
		//if(currentPos!=nil)
		//	[currentPos release];
		currentPos=nil;
		parsingPlace=NO;
	}
	if([elementName isEqualToString:@"name"] && parsingPlace==YES) {
		currentPlacename=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"coordinates"] && parsingPlace==YES) {
		currentPos=currentProp;
		currentProp=nil;
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (currentProp!=nil) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        NSString *currentProp2=[currentProp stringByAppendingString:string];
		//[currentProp release];
		currentProp=[currentProp2 retain];
    }
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"End ok width %d results",[result count]);
	
	[delegate geoEncodeGot:result forRequest:req ];
	result=nil;
	req=nil;
	//if(currentPlacename!=nil)
	//	[currentPlacename release];
	currentPlacename=nil;
	//if(currentPos!=nil)
	//	[currentPos release];
	currentPos=nil;
	currentProp=nil;
	parsingPlace=NO;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Parse error from delegate");

	[delegate geoEncodeGot:result forRequest:req ];
	result=nil;
	req=nil;
	//if(currentPlacename!=nil)
	//	[currentPlacename release];
	currentPlacename=nil;
	//if(currentPos!=nil)
	//	[currentPos release];
	currentPos=nil;
	parsingPlace=NO;
	
}
-(BOOL)geoencode:(NSString*)toEncode {
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsMapsOffline]) return NO;
	if(req!=nil) return NO;
	

	
	NSString *lang=[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsMapsLanguage];
	if(lang==nil) lang=@"en";
	
	NSString* encURL=[GeoEncoder urlencode:toEncode encoding:@"utf8"];
	
	NSString *urlT=[[NSString alloc] initWithFormat:@"http://maps.google.com/maps?ie=UTF8&oe=UTF8&output=kml&q=%@&hl=%@",encURL,lang];
	NSLog(@"Getting geoencode at %@",urlT);
	NSURL *url = [NSURL URLWithString:urlT];
	NSMutableURLRequest *urlReq=[NSMutableURLRequest requestWithURL:url];

	
	[urlReq setValue:@"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1" forHTTPHeaderField:@"User-Agent"];
	//[urlReq setValue:@"image/png,image/*;q=0.8,*/*;q=0.5" forHTTPHeaderField:@"Accept"];
	[urlReq setValue:@"http://maps.google.com/maps" forHTTPHeaderField:@"Referer"];
	
	NSHTTPURLResponse *rep=nil;
	NSError *err=nil;
	
	NSData *dataR = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&rep error:&err];
	
	[url release];
	
	if(dataR!=nil && [dataR length]>0 && [rep statusCode]==200) {

		
		NSXMLParser *xmlParser=[[NSXMLParser alloc] initWithData:dataR];
		[xmlParser setShouldProcessNamespaces:NO];
		[xmlParser setShouldReportNamespacePrefixes:NO];
		[xmlParser setShouldResolveExternalEntities:NO];
		
		if(xmlParser==nil) {
			NSLog(@"Parsing error");
			return NO;
		}
		xmlParser.delegate=self;
		parsingPlace=NO;
		req=[toEncode retain];
		currentPlacename=nil;
		currentPos=nil;
		if(![xmlParser parse]) {
			//[dataR release];
			//[xmlParser release];
			NSLog(@"Parsing error 2");
			return NO;
		}
		//[dataR release];
		//[xmlParser release];
		return YES;
	}
	else return NO;
}
@end
