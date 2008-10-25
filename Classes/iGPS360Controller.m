//
//  iGPS360Controller.m
//  xGPSUtil
//
//  Created by Mathieu on 8/5/08.waitUntilDone:YES
//  Copyright 2008 Xwaves. All rights reserved.
//

// Describe the iGPS360. All communication related and treatment methods should be here.

#import "iGPS360Controller.h"
#include <stdio.h>   /* Standard input/output definitions */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions */
#include <sys/ioctl.h>
#include <math.h>
#include "packet_reader.h"

#define USE_UI

#ifdef USE_UI
#import <UIKit/UIKit.h>
#endif

@implementation iGPS360Controller
-(NSString*)name {
	return @"iGPS360";
}

//Seems not possbile to enable or disable the iGPS360, not implemented so.
- (BOOL)EnableGPS {
	//Not possible
	return YES;
}

//Seems not possbile to enable or disable the iGPS360, not implemented so.
- (BOOL)DisableGPS {
	//Not possible
	return YES;
}

-(void)start {
	//Set the baud rate to 115200
	[super changeSerialSpeed:B115200];
	stopGPSSerial=NO;
	started=YES;
	isEnabled=YES;
	[NSThread detachNewThreadSelector:@selector(threadSerialGPS) toTarget:self withObject:nil];
}
- (id)initWithDelegate:(id)del {
	if((self=[super initWithDelegate:del])) {
		isConnected=YES;
		validLicense=YES;
		serial=@"N/A";
		version_major=1;
		version_minor=0;
	}
	return self;
}
- (void)stop {
	isEnabled=NO;
	stopGPSSerial=YES;
	started=NO;
}
-(void)dealloc {
	[super dealloc];
}

//This method can be used if the GPS doesn't respond anymore. Killing iapd turn off and on the accessory port power.
-(void)resetGPS {
	system("/usr/bin/killall -9 iapd");
}

// Get the GPS version. Seems not possible
-(BOOL)GetVersion {
	return YES;
}

//Get the GPS Serial. Not possible
- (BOOL)GetSerial {
	return YES;
}

-(void) threadSerialGPS {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//Do only if serial port is ok
	if(self.serialHandle>0)
	{
		struct gps_packet_t packet;
		packet_reset(&packet);
		ChangedState* chMsg=[[ChangedState objWithState:SPEED andParent:self] retain];
		NSLog(@"threadSerial(): started...");
		while(!stopGPSSerial) { //Do until we are asked to sop

			//Do a read until we get a right GPS NMEA packet
			while(packet.type<0 && !stopGPSSerial) {
				ssize_t recvd;

				/*@ -modobserver @*/
				recvd = read(self.serialHandle, packet.inbuffer + packet.inbuflen, sizeof(packet.inbuffer) - (packet.inbuflen));


				// Error occured, ignore it for now
				if (recvd <0) {
					if ((errno == EAGAIN) || (errno == EINTR)) {
						continue;
					} else {
						continue;
					}
				}

				//If nothing received (or timeout) continue
				if (recvd == 0) continue;

				//For debugging purpose, not yet used
				//writeDebugSerial((const char*)(packet.inbuffer + packet.inbuflen),recvd);
			
				//parse the received data
				packet_parse(&packet, (size_t) recvd);
			}

			//If we are here it means that we should have a correct NMEA packet in memory or that we are stopped

			//For each buffered data, parse and use the packets
			while(packet.type>=0 && !stopGPSSerial) {
				if(packet.type==1 && isEnabled) {
					//Parse NMEA
					unsigned int mask=nmea_parse((char*)packet.outbuffer,&gps_data);
					
					//Call callbacks according to data changes
					if((unsigned int)(mask & SPEED_SET) == (unsigned int)SPEED_SET){
						chMsg.state=SPEED_SET;
#ifdef USE_UI
						[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
						[delegate gpsChanged:chMsg];
#endif
					}
					if((unsigned int)(mask & LATLON_SET) == (unsigned int)LATLON_SET || (unsigned int)(mask & ALTITUDE_SET) == (unsigned int)ALTITUDE_SET){
						chMsg.state=POS;

#ifdef USE_UI
						[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
					[delegate gpsChanged:chMsg];
#endif
					}
				//Dirty hack to evaluate signal quality
				if(gps_data.fix.mode<2)
					signalQuality=0;
				else if(gps_data.fix.mode==2)
					signalQuality=40;
				else if(gps_data.fix.mode==3)
					signalQuality=80;
				chMsg.state=SIGNAL_QUALITY;
				[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
				}
				
				//Parse the next packet
				packet.type = BAD_PACKET;
				packet_parse(&packet, 0);
			}
			//End of buffered commands, receive the other
		}
		[chMsg release];
	} else {
		NSLog(@"threadSerial(): Serial port error !");
	}
	stopGPSSerial=NO;
	[pool release];
}
@end
