//
//  G-FiController.m
//  G-Fi
//
//  Created by Steven Mattera on 10/22/08.
//  Copyright 2008 PosiMotion. All rights reserved.
//
//	This source code is the property of PosiMotion LLC. It is intended only for the 
//	person or entity to which it was sent to and may contain information that is 
//	privileged, confidential, or otherwise protected from disclosure. Distribution 
//	or copying of this source code, or the information contained herein, to anyone 
//	other than the intended recipient is prohibited, unless otherwise permitted by
//	PosiMotion LLC.
//

#import <sys/ioctl.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/sockio.h>
#import <net/if.h>
#import <errno.h>
#import <net/if_dl.h>
#import <arpa/inet.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <unistd.h>
#import <fcntl.h>
#import "GFiController.h"

#define DROPPED_TOUCH_MOVED_EVENTS_RATIO  (0.8)
#define ZOOM_IN_TOUCH_SPACING_RATIO       (0.75)
#define ZOOM_OUT_TOUCH_SPACING_RATIO      (1.5)
#define MAX_LEN 1024
#define	min(a,b)	((a) < (b) ? (a) : (b))
#define	max(a,b)	((a) > (b) ? (a) : (b))

#define BUFFERSIZE	4000
#define MAXADDRS	32

static char *if_names[MAXADDRS];
static char *ip_names[MAXADDRS];
static char *hw_addrs[MAXADDRS];
static unsigned long ip_addrs[MAXADDRS];

static int   nextAddr = 0;
static int sock;                     /* socket descriptor */
static char recv_str[MAX_LEN+1];     /* buffer to receive string */
static int recv_len;                 /* length of string received */
static struct sockaddr_in from_addr; /* packet source */
static struct ip_mreq mc_req;        /* multicast request structure */
static unsigned int from_len;        /* source addr length */


@implementation GFiController

- (id) init {
	self = [super init];
	if (self != nil) {		
		
	}
	return self;
}


#pragma mark ----
#pragma mark ==== NSTimer Selector Methods ====
#pragma mark ----

- (void)newLocation:(NSTimer *)timer {
	[currentGfiLocation release];
	currentGfiLocation=nil;
	strNMEA = [self getData];
	if(strNMEA != nil) {
		currentGfiLocation = [self parseNMEAData:strNMEA];	
		if(currentGfiLocation != nil) {
			
			gps_data.fix.speed=currentSpeed*KNOTS_TO_MPS;
				
			//Update signal quality
			signalQuality=100;

			gps_data.fix.latitude=currentGfiLocation.coordinate.latitude;
			gps_data.fix.longitude=currentGfiLocation.coordinate.longitude;
			gps_data.fix.altitude=currentGfiLocation.altitude;
			gps_data.fix.mode=3;
			chMsg.state=POS;
			
			[delegate gpsChanged:chMsg];
			chMsg.state=SPEED;
			[delegate gpsChanged:chMsg];
			
		} else {
			signalQuality=0;
			gps_data.fix.mode=0;
			
		}
		chMsg.state=SIGNAL_QUALITY;
		[delegate performSelectorOnMainThread:@selector(gpsChanged:) withObject:chMsg waitUntilDone:YES];
		
	}
}

#pragma mark xGPS Methods


- (BOOL)EnableGPS {
	if(isEnabled) return NO;
	if([self startUDPSocket] == 0) {
		timerNew=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(newLocation:) userInfo:nil repeats:YES];
		[timerNew retain];
		isEnabled=YES;
	} else {
		return NO;
	}
	return YES;
}
- (BOOL)DisableGPS {
	if(!isEnabled) return NO;
	gps_data.fix.mode=0;
	[timerNew invalidate];
	[timerNew release];
	timerNew=nil;
	[self stopUDPSocket];
	isEnabled=NO;
	
	return YES;
}
-(NSString*)name {
	return @"G-Fi GPS";
}

-(void) dealloc {
	[chMsg release];
	[timerNew release];
	[super dealloc];
}
- (id)initWithDelegate:(id)del {
	self=[super initWithDelegate:del];
	version_minor=0;
	version_major=1;
	validLicense=YES;
	
	isConnected=YES;
	
	//Check if speed is supported
	isEnabled=NO;
	
	chMsg=[[ChangedState objWithState:SPEED andParent:self] retain];
	return self;
}
-(BOOL) needSerial {
	return NO;
}


#pragma mark ----
#pragma mark ==== NMEAParser Methods ====
#pragma mark ----

- (CLLocation *)parseNMEAData:(NSString *)data {
	CLLocationCoordinate2D codLatLon;
	float fltAltitude, fltVDOP, fltHDOP, fltSpeed, fltHeading;
	BOOL bolFixed;
	
	NSArray *arySentences = [[[NSMutableArray alloc] initWithArray:[data componentsSeparatedByString:@"\r\n"]] autorelease];
	
	if([arySentences count] > 1) {	
		for(int i=0; i < [arySentences count]; i++) {
			if([[arySentences objectAtIndex:i] length] > 5) {
				NSString *strSentenceType = [[[NSString alloc] initWithString:[[arySentences objectAtIndex:i] substringWithRange:NSMakeRange(0, 6)]] autorelease];
				if([strSentenceType isEqualToString:@"$GPGGA"]) {
					NSArray *arySentence = [[[NSMutableArray alloc] initWithArray:[[arySentences objectAtIndex:i] componentsSeparatedByString:@","]] autorelease];
					
					//Latitude
					
					if([[arySentence objectAtIndex:3] isEqualToString:@"N"]) {
						float fltDegrees = [[[arySentence objectAtIndex:2] substringWithRange:NSMakeRange(0, 2)] floatValue];
						float fltMinutes = [[[arySentence objectAtIndex:2] substringWithRange:NSMakeRange(2, [[arySentence objectAtIndex:2] length]-2)] floatValue];
						
						codLatLon.latitude = fltDegrees + (fltMinutes/60);
					}
					else if([[arySentence objectAtIndex:3] isEqualToString:@"S"]) {
						float fltDegrees = [[[arySentence objectAtIndex:2] substringWithRange:NSMakeRange(0, 2)] floatValue];
						float fltMinutes = [[[arySentence objectAtIndex:2] substringWithRange:NSMakeRange(2, [[arySentence objectAtIndex:2] length]-2)] floatValue];
						
						codLatLon.latitude = (fltDegrees + (fltMinutes/60))*-1;
					}
					
					//Longitude
					
					if([[arySentence objectAtIndex:5] isEqualToString:@"E"]) {
						float fltDegrees = [[[arySentence objectAtIndex:4] substringWithRange:NSMakeRange(0, 3)] floatValue];
						float fltMinutes = [[[arySentence objectAtIndex:4] substringWithRange:NSMakeRange(3, [[arySentence objectAtIndex:4] length]-3)] floatValue];
						
						codLatLon.longitude = fltDegrees + (fltMinutes/60);
					}
					else if([[arySentence objectAtIndex:5] isEqualToString:@"W"]) {
						float fltDegrees = [[[arySentence objectAtIndex:4] substringWithRange:NSMakeRange(0, 3)] floatValue];
						float fltMinutes = [[[arySentence objectAtIndex:4] substringWithRange:NSMakeRange(3, [[arySentence objectAtIndex:4] length]-3)] floatValue];
						
						codLatLon.longitude = (fltDegrees + (fltMinutes/60))*-1;
					}
					
					//Fix
					if([[arySentence objectAtIndex:6] intValue] != 0)
						bolFixed = YES;
					else
						bolFixed = NO;					
					
					//Altitude
					
					fltAltitude = [[arySentence objectAtIndex:9] floatValue];
					
					//HDOP
					
					fltHDOP = [[arySentence objectAtIndex:8] floatValue];
				}
				else if([strSentenceType isEqualToString:@"$GPGSA"]) {
					NSArray *arySentence = [[[NSMutableArray alloc] initWithArray:[[arySentences objectAtIndex:i] componentsSeparatedByString:@","]] autorelease];
					
					//VDOP
					
					fltVDOP = [[arySentence objectAtIndex:17] floatValue];
				}
				else if([strSentenceType isEqualToString:@"$GPRMC"]) {
					NSArray *arySentence = [[[NSMutableArray alloc] initWithArray:[[arySentences objectAtIndex:i] componentsSeparatedByString:@","]] autorelease];
					
					//Speed
					
					fltSpeed = [[arySentence objectAtIndex:7] floatValue];
					
					//Heading
					
					fltHeading = [[arySentence objectAtIndex:8] floatValue];
				}
			}
		}
	}
	else {
		return nil;
	}
	CLLocation *newLocation = nil;
	if(bolFixed == YES) {
		newLocation = [[CLLocation alloc] initWithCoordinate:codLatLon altitude:fltAltitude horizontalAccuracy:fltHDOP verticalAccuracy:fltVDOP timestamp:[NSDate date]];
		currentHeading = fltHeading;
		currentSpeed = fltSpeed;
	}
	
	
	return newLocation;
}

#pragma mark ----
#pragma mark ==== IP Address Detection Methods ====
#pragma mark ----

- (void)InitAddresses {
	int i;
	for (i=0; i<MAXADDRS; ++i)
	{
		if_names[i] = ip_names[i] = hw_addrs[i] = NULL;
		ip_addrs[i] = 0;
	}
}

- (void)FreeAddresses {
	int i;
	for (i=0; i<MAXADDRS; ++i)
	{
		if (if_names[i] != 0) free(if_names[i]);
		if (ip_names[i] != 0) free(ip_names[i]);
		if (hw_addrs[i] != 0) free(hw_addrs[i]);
		ip_addrs[i] = 0;
	}
	[self InitAddresses];
}

- (void)GetIPAddresses {
	int                 i, len, flags;
	char                buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
	struct ifconf       ifc;
	struct ifreq        *ifr, ifrcopy;
	struct sockaddr_in	*sin;
	
	char temp[80];
	
	int sockfd;
	
	for (i=0; i<MAXADDRS; ++i)
	{
		if_names[i] = ip_names[i] = NULL;
		ip_addrs[i] = 0;
	}
	
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd < 0)
	{
		perror("socket failed");
		return;
	}
	
	ifc.ifc_len = BUFFERSIZE;
	ifc.ifc_buf = buffer;
	
	if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
	{
		perror("ioctl error");
		return;
	}
	
	lastname[0] = 0;
	
	for (ptr = buffer; ptr < buffer + ifc.ifc_len; )
	{
		ifr = (struct ifreq *)ptr;
		len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
		ptr += sizeof(ifr->ifr_name) + len;	// for next one in buffer
		
		if (ifr->ifr_addr.sa_family != AF_INET)
		{
			continue;	// ignore if not desired address family
		}
		
		if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL)
		{
			*cptr = 0;		// replace colon will null
		}
		
		if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0)
		{
			continue;	/* already processed this interface */
		}
		
		memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
		
		ifrcopy = *ifr;
		ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
		flags = ifrcopy.ifr_flags;
		if ((flags & IFF_UP) == 0)
		{
			continue;	// ignore if interface not up
		}
		
		if_names[nextAddr] = (char *)malloc(strlen(ifr->ifr_name)+1);
		if (if_names[nextAddr] == NULL)
		{
			return;
		}
		strcpy(if_names[nextAddr], ifr->ifr_name);
		
		sin = (struct sockaddr_in *)&ifr->ifr_addr;
		strcpy(temp, inet_ntoa(sin->sin_addr));
		
		ip_names[nextAddr] = (char *)malloc(strlen(temp)+1);
		if (ip_names[nextAddr] == NULL)
		{
			return;
		}
		strcpy(ip_names[nextAddr], temp);
		
		ip_addrs[nextAddr] = sin->sin_addr.s_addr;
		
		++nextAddr;
	}
	
	close(sockfd);
}

#pragma mark ----
#pragma mark ==== UDP Multicast Methods ====
#pragma mark ----

- (int)startUDPSocket {
	[self InitAddresses];
	[self GetIPAddresses];
	
	int flag_on = 1;              /* socket option flag */
	struct sockaddr_in mc_addr;   /* socket address structure */
	char* mc_addr_str = "239.1.1.1";            /* multicast IP address */
	unsigned short mc_port = 10000;       /* multicast port */
	
	/* create socket to join multicast group on */
	if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		printf("socket() failed");
		return -1;
	}	
	
	int flags = fcntl(sock, F_GETFL);
	flags |= O_NONBLOCK;
	fcntl(sock, F_SETFL, flags);
	
	if ((setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &flag_on, sizeof(flag_on))) < 0) {
		printf("setsockopt() failed - %u", (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &flag_on, sizeof(flag_on))));
		return -1;
	}
	
	/* construct a multicast address structure */
	memset(&mc_addr, 0, sizeof(mc_addr));
	mc_addr.sin_family      = AF_INET;
	mc_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	mc_addr.sin_port        = htons(mc_port);
	
	/* bind to multicast address to socket */
	if ((bind(sock, (struct sockaddr *) &mc_addr, sizeof(mc_addr))) < 0) {
		printf("bind() failed");
		return -1;
	}
	
	mc_req.imr_multiaddr.s_addr = inet_addr(mc_addr_str);
	mc_req.imr_interface.s_addr = inet_addr(ip_names[1]);
	
	if ((setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, (void*) &mc_req, sizeof(mc_req))) < 0) {
		printf("setsockopt() failed - %u\n", (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, (void*) &mc_req, sizeof(mc_req))));
		return -1;
	}	
	
	return 0;
}

- (NSString *)getData {
	/* clear the receive buffers & structs */
	memset(recv_str, 0, sizeof(recv_str));
	from_len = sizeof(from_addr);
	memset(&from_addr, 0, from_len);
	errno=0;
	if ((recv_len = recvfrom(sock, recv_str, MAX_LEN, 0, (struct sockaddr*)&from_addr, &from_len)) < 0) {
		//printf("recvfrom() failed: %s\n",strerror(errno));
		return nil;
	}
	
	return [NSString stringWithFormat:@"%s", recv_str];
}

- (int)stopUDPSocket {
	/* send a DROP MEMBERSHIP message via setsockopt */
	if ((setsockopt(sock, IPPROTO_IP, IP_DROP_MEMBERSHIP, (void*) &mc_req, sizeof(mc_req))) < 0) {
		printf("setsockopt() failed: %s\n",strerror(errno));
		return -1;
	}
	
	close(sock);
	
	return 0;
}

@end