//
//  GPXLogger.m
//  xGPS
//
//  Created by Mathieu on 19.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GPXLogger.h"


@implementation GPXLogger
-(void)startLogging {
	if(logging) return;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"xgps_gpx"];
	
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
	
	int i=0;
	NSString *file=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d.log",[[[[NSDate date] description] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@":" withString:@"-"],i]];

	fp = fopen ([file UTF8String],"r");
	while(fp!=NULL)
	{
		i++;
		file=[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log",[[NSDate date] description]]];
		
		fp = fopen ([file UTF8String],"r");
		
		fclose(fp);
	}
	
	NSLog(@"Start logging to %@",file);

	
	fp = fopen ([file UTF8String],"w");
	if(fp!=NULL) {
		fprintf(fp,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<gpx version=\"1.1\" creator=\"xGPS - http://xgps.xwaves.net\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.topografix.com/GPX/1/1\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">\n<trk><trkseg>\n");
		fflush(fp);
		logging=YES;
	}else {
		fprintf(stderr,"Error while opening GPX log file: %s",strerror(errno));
	}
}
-(void)stopLogging {
	if(fp==NULL || !logging) return;
	logging=false;
	fprintf(fp,"\n</trkseg></trk>\n</gpx>");
	fclose(fp);
	fp=NULL;
}
-(void)gpsSignalChanged:(BOOL)_hasSignal {
	if(hasSignal!=_hasSignal) {
		hasSignal=_hasSignal;
		if(logging && fp!=NULL)
		fprintf(fp,"\n</trkseg>\n<trkseg>");
	}
}
-(void)logGPXPoint:(float)lat lon:(float)lon alt:(float)alt speed:(float)speed fix:(int) fix sat:(int)sat {
	if(fp==NULL || !logging) return;
	
	time_t rawtime;
	time(&rawtime);
	struct tm *tm = gmtime ( &rawtime );
	
	/*<trkpt lat="48.693754550" lon="0.786620167">
	 <ele>215.261000</ele>
	 <time>2008-07-27T15:22:24Z</time>
	 <course>184.220001</course>
	 <speed>0.000556</speed>
	 <fix>3d</fix>
	 <sat>8</sat>
	 <hdop>1.280000</hdop>
	 <vdop>1.560000</vdop>
	 <pdop>2.020000</pdop>
	 </trkpt>*/
	char *fix_str="none";
	if(fix<2)
		fix_str="none";
	else if(fix==2)
		fix_str="2d";
	else if(fix==3)
		fix_str="3d";
	//2008-07-27T15:22:23Z
	
	fprintf(fp,"<trkpt lat=\"%f\" lon=\"%f\">",lat,lon);
	fprintf(fp,"<ele>%f</ele>",alt);
	fprintf(fp,"<time>%d-%d-%dT%d:%d:%dZ</time>",tm->tm_year+1900,tm->tm_mon+1,tm->tm_mday,tm->tm_hour,tm->tm_min,tm->tm_sec);
	fprintf(fp,"<speed>%f</speed>",speed);
	fprintf(fp,"<fix>%s</fix>",fix_str);
	if(fix>=2 && sat>0)
	fprintf(fp,"<sat>%d</sat>",sat);
	fprintf(fp,"</trkpt>");	
}
@end
