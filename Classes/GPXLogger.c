//
//  GPXLogger.c
//  xGPS
//
//  Created by Mathieu on 10/30/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#include "GPXLogger.h"
#include <stdio.h>
#include <time.h>
#include <errno.h>
#include <string.h>
#define LOG_FILE "/tmp/xgps_gpxtrack.log"
static FILE* fp=NULL;
const char* getGPXFilename() {
	return LOG_FILE;
}


void startGPXLogEngine() {
	if(fp!=NULL) return;
	char newFile=1;
	fp = fopen (LOG_FILE,"r");
	if(fp!=NULL)
	{
		newFile=0;
		fclose(fp);
	}
	
	fp = fopen (LOG_FILE,"a");
	if(fp!=NULL) {
		if(newFile==0) {
			//Delete the </gpx>
			//fseek (fp, 0, SEEK_END);
			//int size=ftell (fp)-6;
			//fseek(fp,size,SEEK_SET);
			fprintf(fp,"<trk><trkseg>\n");
		}
		else {
			//GPX Header
			fflush(fp);
			fprintf(fp,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<gpx version=\"1.1\" creator=\"xGPS - http://xgps.xwaves.net\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.topografix.com/GPX/1/1\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\">\n<trk><trkseg>\n");
		}
		fflush(fp);
	}else {
		fprintf(stderr,"Error while opening GPX log file: %s",strerror(errno));
	}
}
void logGPXPoint(float lat, float lon, float alt, float speed, int fix, int sat) {
	if(fp==NULL) return;

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
	
	fprintf(fp,"<trkpt lat=\"%f\" lon=\"%f\">\n",lat,lon);
	fprintf(fp,"<ele>%f</ele>\n",alt);
	fprintf(fp,"<time>%d-%d-%dT%d:%d:%dZ</time>\n",tm->tm_year+1900,tm->tm_mon,tm->tm_mday,tm->tm_hour,tm->tm_min,tm->tm_sec);
	fprintf(fp,"<speed>%f</speed>\n",speed);
	fprintf(fp,"<fix>%s</fix>\n",fix_str);
	fprintf(fp,"<sat>%d</sat>\n",sat);
	fprintf(fp,"</trkpt>\n");
}
void stopGPXLogEngine() {
	if(fp==NULL) return;
	fprintf(fp,"\n</trkseg></trk>\n");
	fclose(fp);
	fp=NULL;
}