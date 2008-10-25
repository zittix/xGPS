//
//  xGPSController.m
//  xGPSUtil
//
//  Created by Mathieu on 8/5/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "xGPSController.h"

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


#ifdef USE_UI
#import <UIKit/UIKit.h>
#endif

@implementation xGPSController
-(NSString*)name {
	return @"xGPS Module";
}
- (BOOL)canUpdateFirmware {
	if(isConnected && version_major>0 && version_minor>=0) {
		if(version_major*10+version_minor<VERSION_INTEGER)
			return YES;
		else
			return NO;
	}
	else {
		return NO;
	}
}

- (BOOL)EnableGPS {
	isEnabled=YES;
	return [self sendCommand:"o"];
}
- (BOOL)DisableGPS {
	isEnabled=NO;
	return [self sendCommand:"f"];
}
- (BOOL)PutBootloaderMode {
	char cmd[2]= {0x0f,0x0f};
	return [self sendCommand:cmd];
}
-(void)checkConnection {
	BOOL val;
	[lockReceivedOk lock];
	val=hasReceivedOK;
	[lockReceivedOk unlock];
	if(!hasReceivedOK) {
		if(firstStart) {
			system("/usr/bin/killall -9 iapd");
			firstStart=NO;
		}
		if(isConnected) {
			isConnected=NO;
			[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:CONNECTION_CHANGE andParent:self] waitUntilDone:YES];
		}
	} else {
		if(!isConnected) {
			isConnected=YES;
			[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:[ChangedState objWithState:CONNECTION_CHANGE andParent:self] waitUntilDone:YES];
		}
	}
	[lockReceivedOk lock];
	hasReceivedOK=NO;
	[lockReceivedOk unlock];
	[self sendCommand:"t"];
	
	//Reset the timer to a longer interval if connected
	if(isConnected && checkTimer.timeInterval!=12) {
		[checkTimer invalidate];
		checkTimer=[NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(checkConnection) userInfo:nil repeats:YES];
	} else if(!isConnected && checkTimer.timeInterval!=2) {
		[checkTimer invalidate];
		checkTimer=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkConnection) userInfo:nil repeats:YES];
	}
}
-(void)start {
	
	[super changeSerialSpeed:B19200];
	
	stopGPSSerial=NO;
	started=YES;
	[NSThread detachNewThreadSelector:@selector(threadSerialGPS) toTarget:self withObject:nil];
	checkTimer=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkConnection) userInfo:nil repeats:YES];
	
	//Check if online or not
	
	[self sendCommand:"v"];
}
- (id)initWithDelegate:(id)del {
	self=[super initWithDelegate:del];
	
	firstStart=YES;
	
	hasReceivedOK=NO;
	validLicense=YES;
	lockReceivedOk=[[NSLock alloc] init];
	
	
	return self;
}
- (void)stop {
	NSLog(@"Stoppig xgps");
	[checkTimer invalidate];
	[self sendCommand:"f"];
	
	sleep(1);
	isEnabled=NO;
	stopGPSSerial=YES;
	started=NO;
}
-(void)dealloc {
	NSLog(@"Deallocate xgps");
	[lockReceivedOk release];
	[super dealloc];
}
-(void)resetGPS {
	system("/usr/bin/killall -9 iapd");
}
-(BOOL)GetVersion {
	return [self sendCommand:"v"];
}
- (BOOL)GetSerial {
	return [self sendCommand:"s"];
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
			
			
			while(packet.type<0 && !stopGPSSerial) {
				ssize_t recvd;
				
				/*@ -modobserver @*/
				recvd = read(self.serialHandle, packet.inbuffer + packet.inbuflen, sizeof(packet.inbuffer) - (packet.inbuflen));
				
				//printf("%d raw bytes read: %s\n",
				//		(int)recvd,packet.inbuffer+packet.inbuflen);
				
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
			
			//NSLog(@"End loop recept.");
			
			//NSLog(@"Packet type: %d",packet.type);
			while(packet.type>=0 && !stopGPSSerial) {
				if(packet.type==0) {
					//XGPS PARSER
					writeDebugMessage([[NSString stringWithFormat:@"Received command: '%s'",packet.outbuffer] UTF8String]);
					//printf("Command: '%s'\n",packet.outbuffer);
					if(*packet.outbuffer!='#') continue;
					char *cmd=(char*)packet.outbuffer;
					//Check where is the first $
					
					
					//Check if xgps command
					if(cmd!=NULL) {
						if(strncmp(cmd,"#Version",8)==0 && strlen(cmd)>11) {
							[lockReceivedOk lock];
							hasReceivedOK=YES;
							[lockReceivedOk unlock];
							cmd+=9;
							sscanf(cmd,"%d.%d\r\n",&version_major,&version_minor);
							firstStart=NO;
							//NSLog(@"threadSerial(): #Version  got: %d.%d",version_major,version_minor);
							if(version_major>=0 && version_minor>=0) {
								chMsg.state=VERSION_CHANGE;
#ifdef USE_UI
								[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
								[delegate gpsChanged:chMsg];
#endif
							}
							if(!isConnected) {
								isConnected=YES;
								[self sendCommand:"s"];
								chMsg.state=CONNECTION_CHANGE;
#ifdef USE_UI
								[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
								[delegate gpsChanged:chMsg];
#endif
							}
						} else if(strncmp(cmd,"#xgpsBoot",9)==0) {
							[lockReceivedOk lock];
							hasReceivedOK=YES;
							[lockReceivedOk unlock];
							isConnected=YES;
							[self sendCommand:"s"];
							chMsg.state=CONNECTION_CHANGE;
#ifdef USE_UI
							[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
							[delegate gpsChanged:chMsg];
#endif
						} else if(strncmp(cmd,"#xgpsOK",7)==0) {
							[lockReceivedOk lock];
							hasReceivedOK=YES;
							[lockReceivedOk unlock];
							
							if(!isConnected) {
								isConnected=YES;
								chMsg.state=CONNECTION_CHANGE;
#ifdef USE_UI
								[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
								[delegate gpsChanged:chMsg];
#endif
							}
						} else if(strncmp(cmd,"#xgpsON",7)==0) {
							isEnabled=YES;
							chMsg.state=STATE_CHANGE;
#ifdef USE_UI
							[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
							[delegate gpsChanged:chMsg];
#endif
							if(!isConnected) {
								isConnected=YES;
								chMsg.state=CONNECTION_CHANGE;
#ifdef USE_UI
								[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
								[delegate gpsChanged:chMsg];
#endif
							}
						} else if(strncmp(cmd,"#xgpsOFF",8)==0) {
							isEnabled=NO;
							chMsg.state=STATE_CHANGE;
#ifdef USE_UI
							[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
							[delegate gpsChanged:chMsg];
#endif
							if(!isConnected) {
								isConnected=YES;
								chMsg.state=CONNECTION_CHANGE;
#ifdef USE_UI
								[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
								[delegate gpsChanged:chMsg];
#endif
							}
						} else if(strncmp(cmd,"#Serial ",8)==0 && strlen(cmd)>15) {
							char c1[2],c2[2],c3[2],c4[2];
							cmd+=8;
							sscanf(cmd,"%2c%2c%2c%2c\r\n",c1,c2,c3,c4);
							char serialt[14];
							snprintf(serialt,14,"%c%c-%c%c-%c%c-%c%c",*c1,*(c1+1),*c2,*(c2+1),*c3,*(c3+1),*c4,*(c4+1));
							//NSLog(@"threadSerial(): #Serial  got: %s",serialt);
							[serial release];
							serial=[[NSString alloc] initWithCString:serialt];
							if([serial length]>0) {
								chMsg.state=SERIAL;
#ifdef USE_UI
								[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
								[delegate gpsChanged:chMsg];
#endif
							}
							if(!isConnected) {
								isConnected=YES;
								chMsg.state=CONNECTION_CHANGE;
#ifdef USE_UI
								[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
#else
								[delegate gpsChanged:chMsg];
#endif
							}
							[self sendCommand:"q"];
						}
						
					}
				} else if(packet.type==1) {
					//NMEA
					//[self writeDebugMessage:[NSString stringWithFormat:@"Received data: '%s'",packet.outbuffer]];
					unsigned int mask=nmea_parse((char*)packet.outbuffer,&gps_data);
					//printf("Sat %d - Lat/Lon: %f %f - Alt: %f - Speed: %f m/s\n",gps_data.satellites,gps_data.fix.latitude,gps_data.fix.longitude,gps_data.fix.altitude,gps_data.fix.speed);
					if((unsigned int)(mask & SPEED_SET) == (unsigned int)SPEED_SET){
						chMsg.state=SPEED;
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
		NSLog(@"threadSerial(): End of thread of xGPS");
	} else {
		NSLog(@"threadSerial(): Serial port error !");
	}
	
	stopGPSSerial=NO;
	[pool release];
}
@end
