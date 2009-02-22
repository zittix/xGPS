//
//  xGPSController.m
//  xGPSUtil
//
//  Created by Mathieu on 8/5/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "iGPSDController.h"

//
//  LocationWrapper.m
//  xGPS
//
//  Created by Mathieu on 6/16/08.
//  Copyright 2008 Xwaves. All rights reserved.
//
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

#import <CommonCrypto/CommonDigest.h>
#ifdef USE_UI
#import <UIKit/UIKit.h>
#endif
#import "xGPSAppDelegate.h"
@implementation iGPSDController
-(NSString*)name {
	return @"iGPSD";
}
- (BOOL)EnableGPS {
	isEnabled=YES;
	return YES;
}
- (BOOL)DisableGPS {
	isEnabled=NO;
	return YES;
}
-(BOOL)needLicense {
	return YES;
}
-(BOOL)checkLicense:(NSString*)s {
	//NSLog(@"Unique ID:%@",[UIDevice currentDevice].uniqueIdentifier);
	NSString *url=[NSString stringWithFormat:@"http://license.xwaves.net/checkLicense.php?license=%@&prod=xgps&device=%@",s,[UIDevice currentDevice].uniqueIdentifier];
	NSString* hash=[self downloadPage:url];
	if(hash==nil) return NO;
	//NSLog(@"License hash: '%@'",hash);
	unsigned char hashedChars[50];
	memset(hashedChars,50,0);
	NSString* inputString=[NSString stringWithFormat:@"xgpslicensenumbervalid:%@device:%@",s,[UIDevice currentDevice].uniqueIdentifier];
	CC_SHA1([inputString UTF8String],
			  [inputString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 
			  hashedChars);

	NSString *computed=[NSString stringWithCString:""];
	for(int i=0;i<20;i++) {
		computed=[computed stringByAppendingFormat:@"%02x",hashedChars[i]];
	}
	//hashedChars[20]=0;	
	//NSLog(@"Computed hash '%@'\n",computed);
	if([computed isEqualToString:hash]){
		license=[s retain];
		validLicense=YES;
		isConnected=YES;
		[[NSUserDefaults standardUserDefaults] setObject:license forKey:kSettingsLicense];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingsLicenseOK];
		[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:CONNECTION_CHANGE andParent:self] waitUntilDone:NO];

	return YES;
	}else{
		return NO;	
	}
}
-(void)start {
	[super changeSerialSpeed:B38400];
	NSLog(@"iGPS - initWithDelegate()");
	stopGPSSerial=NO;
	started=YES;
	[NSThread detachNewThreadSelector:@selector(threadSerialGPS) toTarget:self withObject:nil];
	
}
- (id)initWithDelegate:(id)del {
	if((self=[super initWithDelegate:del])) {
	version_minor=0;
	version_major=1;
	
	isConnected=YES;
	validLicense=NO;
	isEnabled=NO;
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsLicenseOK]) {
		validLicense=YES;
		license=[[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsLicense] retain];
	}
	}
	return self;
}
-(void)dealloc {
	[super dealloc];
	if(license!=nil) {
		[license release];	
	}
}


-(void) threadSerialGPS {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];


	if(self.serialHandle>0)
	{
		struct gps_packet_t packet;
		packet_reset(&packet);
		ChangedState* chMsg=[[ChangedState objWithState:SPEED andParent:self] retain];
		NSLog(@"threadSerial(): started...");
		while(!stopGPSSerial) {
		
			ssize_t recvd;
			while(packet.type<0 && !stopGPSSerial) {
				

				/*@ -modobserver @*/
				
				//NSLog(@"Reading up to %d chars",sizeof(packet.inbuffer) - (packet.inbuflen));
				recvd = read(self.serialHandle, packet.inbuffer + packet.inbuflen, sizeof(packet.inbuffer) - (packet.inbuflen));
//
				//printf("%d raw bytes read\n",
				//		(int)recvd);

				if(recvd<0)
				printf("Receive error: %s\n", strerror(errno));
				/*@ +modobserver @*/
				if (recvd == -1) {
					if ((errno == EAGAIN) || (errno == EINTR)) {
						continue;;
					} else {
						continue;
					}
				}

				if (recvd == 0) continue;

				
				writeDebugSerial((const char*)(packet.inbuffer + packet.inbuflen),recvd);
			
				
				packet_parse(&packet, (size_t) recvd);
				
			}
			while(packet.type>=0 && !stopGPSSerial) {
			//NSLog(@"End loop recept.");
	
			//NSLog(@"Packet type: %d",packet.type);

			if(packet.type==1 && isEnabled) {
				//NMEA
				 writeDebugMessage([[NSString stringWithFormat:@"Received data: '%s'",packet.outbuffer] UTF8String]);
				unsigned int mask=nmea_parse((char*)packet.outbuffer,&gps_data);
				if(((unsigned int)(mask & SPEED_SET) == (unsigned int)SPEED_SET) && validLicense){
					chMsg.state=SPEED;
#ifdef USE_UI
					[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
					[delegate gpsChanged:chMsg];
#endif
				}
				if(((unsigned int)(mask & LATLON_SET) == (unsigned int)LATLON_SET || (unsigned int)(mask & ALTITUDE_SET) == (unsigned int)ALTITUDE_SET) && validLicense){
					chMsg.state=POS;
#ifdef USE_UI
					[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
					[delegate gpsChanged:chMsg];
#endif
				}
				if(gps_data.fix.mode<2)
					signalQuality=0;
				else if(gps_data.fix.mode==2)
					signalQuality=40;
				else if(gps_data.fix.mode==3)
					signalQuality=80;
				chMsg.state=SIGNAL_QUALITY;
				[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
			}

			//packet_reset(&packet);
			packet.type = BAD_PACKET;
			
				packet_parse(&packet, 0);
				
			}
			//NSLog(@"threadSerial(): End of analysing -> Next command");
		}
		[chMsg release];
		NSLog(@"threadSerial(): End of thread");
	} else {
		NSLog(@"threadSerial(): Serial port error !");
	}

	stopGPSSerial=NO;
	[pool release];
}
@end
