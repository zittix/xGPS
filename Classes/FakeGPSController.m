//
//  FakeGPSController.m
//  xGPS
//
//  Created by Mathieu on 9/26/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "FakeGPSController.h"


@implementation FakeGPSController

- (BOOL)EnableGPS {
	if(tmrGPS==nil)
	tmrGPS=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(gpsUpdate) userInfo:nil repeats:YES];
	
	isEnabled=YES;
	currentIndex=0;
	return YES;
}
- (BOOL)DisableGPS {
	if(tmrGPS!=nil) {
		[tmrGPS invalidate];
		tmrGPS=nil;
	}
	memset(&gps_data,0,sizeof(struct gps_data_t));
	isEnabled=NO;
		return YES;
}
-(NSString*)name {
	return @"Fake GPS";
}
-(void) dealloc {
	[pos release];
	[super dealloc];
	[chMsg release];
}
- (id)initWithDelegate:(id)del {
	self=[super initWithDelegate:del];
	pos=[[PositionObj alloc] init];
	pos.x=48.847639;
	pos.y=2.367715;
	version_minor=0;
	version_major=1;
	validLicense=YES;
	isConnected=YES;
	chMsg=[[ChangedState objWithState:SPEED andParent:self] retain];
	posArray=[[NSMutableArray alloc] initWithCapacity:5];
	[self loadGPX];
	return self;
}
-(void)loadGPX {
	if(gpxLoaded) return;
	
	NSString *file=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"track.gpx"];

	NSXMLParser *xmlParser=[[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:file]];
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
			[xmlParser release];
		}
	
}


- (void)parserDidStartDocument:(NSXMLParser *)parser {
	NSLog(@"Parser start...");
	[posArray removeAllObjects];
	currentIndex=0;
	gpxLoaded=NO;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	//NSLog(@"Found start element %@",elementName);
	if([elementName isEqualToString:@"trkseg"] && parsingTrackSeg==NO) {
		parsingTrackSeg=YES;
	}
	if([elementName isEqualToString:@"trkpt"] && parsingTrackSeg==YES && parsingTrackPoint==NO) {
		parsingTrackPoint=YES;
		currentLat=[attributeDict valueForKey:@"lat"];
		currentLon=[attributeDict valueForKey:@"lon"];
	}
	if([elementName isEqualToString:@"ele"] && parsingTrackPoint==YES && currentAlt==nil) {
		currentProp=[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"speed"] && parsingTrackPoint==YES && currentSpeed==nil) {
		currentProp=[[NSMutableString alloc] init];
	}
	if([elementName isEqualToString:@"fix"] && parsingTrackPoint==YES && currentFix==nil) {
		currentProp=[[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if([elementName isEqualToString:@"trkpt"]) {
		if( parsingTrackPoint && currentLat!=nil && currentLon!=nil && currentAlt!=nil && currentSpeed!=nil && currentFix!=nil) {

				float lon=[currentLon floatValue];
				float lat=[currentLat floatValue];
				float alt=[currentAlt floatValue];
				float speed=[currentSpeed floatValue];
			int fix;
			if([currentFix isEqualToString:@"3d"])
				fix=3;
			else if([currentFix isEqualToString:@"2d"])
				fix=2;
			else
				fix=0;
				
			PositionObj *p=[PositionObj positionWithX:lat y:lon];
			NSDictionary* dict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:lat],@"lat",[NSNumber numberWithFloat:lon],@"lon",[NSNumber numberWithFloat:alt],@"alt",[NSNumber numberWithFloat:speed],@"speed",[NSNumber numberWithInt:fix],@"fix",p,@"pos",nil];
				
			[posArray addObject:dict];
		} else {
			NSLog(@"Invalid placemark");
		}
		[currentAlt release];
		[currentSpeed release];
		[currentFix release];
		currentLon=nil;
		currentLat=nil;
		currentAlt=nil;
		currentFix=nil;
		currentSpeed=nil;

		parsingTrackPoint=NO;
		[currentProp release];
		currentProp=nil;
	}
	if([elementName isEqualToString:@"ele"] && parsingTrackPoint==YES && currentAlt==nil) {
		currentAlt=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"speed"] && parsingTrackPoint==YES && currentSpeed==nil) {
		currentSpeed=currentProp;
		currentProp=nil;
	}
	if([elementName isEqualToString:@"fix"] && parsingTrackPoint==YES && currentFix==nil) {
		currentFix=currentProp;
		currentProp=nil;
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (currentProp!=nil) {
		[currentProp appendString:string];
    }
}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSLog(@"End GPX with %d points",[posArray count]);
	
	if([posArray count]>0){
		gpxLoaded=YES;
	}
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Parse error from delegate");
	
}
-(BOOL) needSerial {
	return NO;
}
- (void)gpsUpdate {
	
	if(gpxLoaded && currentIndex<[posArray count]) {
		NSDictionary *dict=[posArray objectAtIndex:currentIndex];
		gps_data.fix.speed=[[dict valueForKey:@"speed"] floatValue];
		pos.x=gps_data.fix.latitude=[[dict valueForKey:@"lat"] floatValue];
		pos.y=gps_data.fix.longitude=[[dict valueForKey:@"lon"] floatValue];
		gps_data.fix.altitude=[[dict valueForKey:@"alt"] floatValue];
		gps_data.fix.mode=[[dict valueForKey:@"fix"] intValue];
		currentIndex++;
	}else {
	
	gps_data.fix.speed=6;
	gps_data.fix.latitude=pos.x;
	gps_data.fix.longitude=pos.y;
	gps_data.fix.altitude=500;
	gps_data.fix.mode=3;
	}
	chMsg.state=POS;
#ifdef USE_UI
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
	chMsg.state=SPEED;
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
	[delegate gpsChanged:chMsg];
	chMsg.state=SPEED;
	[delegate gpsChanged:chMsg];
#endif
	
	//Update signal quality
	signalQuality=100;
	
	chMsg.state=SIGNAL_QUALITY;
	[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
	pos.x+=0.0001;
	pos.y+=0.0001;
}
@end
