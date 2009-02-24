//
//  GPSController.m
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import "GPSController.h"
#include <stdio.h>   /* Standard input/output definitions */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */

#include <sys/ioctl.h>
#include <math.h>
#include "packet_reader.h"
#define GPSPORT "/dev/tty.iap"
//#define GPSPORT "/dev/tty.gpsholux"
#define USE_UI
static FILE* fserial;
static FILE* fmsg;
static BOOL hasAlreadyShownSerialError=NO;
static int serialHandle=-1;
void writeDebugMessage(const char*msg) {
	if (fmsg != 0) fprintf(fmsg, "%s\n", msg);
}
void writeDebugSerial(const char*msg,int len) {
	if (fserial != 0) fwrite(msg,1,len,fserial);
}


@implementation GPSController
@synthesize delegate;
@synthesize debug;
@synthesize serial;
@synthesize version_minor;
@synthesize version_major;
@synthesize isEnabled;
@synthesize isConnected;
@synthesize gps_data;
@synthesize validLicense;
@synthesize license;
@synthesize started;
@synthesize signalQuality;
-(BOOL)hasAlreadyShownSerialError {
	return hasAlreadyShownSerialError;
}
-(int)serialHandle {
	return serialHandle;
}
-(void)setHasAlreadyShownSerialError {
	hasAlreadyShownSerialError=YES;
}
-(void)start {
	stopGPSSerial=NO;
	started=YES;
}
-(int)_openSerialPort:(const char*)port speed:(speed_t)s {
	NSLog(@"Opening serial for gps %@",self.name);
	int fileDescriptor = -1;
	struct termios options;
	struct termios gOriginalTTYAttrs;
	// Open the serial port read/write, with no controlling terminal, and don't wait for a connection.
	// The O_NONBLOCK flag also causes subsequent I/O on the device to be non-blocking.
	// See open(2) ("man 2 open") for details.
	
	fileDescriptor = open(port, O_RDWR | O_NOCTTY | O_NONBLOCK);
	if (fileDescriptor == -1) {
		NSLog(@"Error opening serial port %s - %s(%d).\n", port, strerror(errno), errno);
		goto error;
	}
	
	// Note that open() follows POSIX semantics: multiple open() calls to the same file will succeed
	// unless the TIOCEXCL ioctl is issued. This will prevent additional opens except by root-owned
	// processes.
	// See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
	
	if (ioctl(fileDescriptor, TIOCEXCL) == -1) {
		NSLog(@"Error setting TIOCEXCL on %s - %s(%d).\n", port, strerror(errno), errno);
		goto error;
	}
	
	// Now that the device is open, clear the O_NONBLOCK flag so subsequent I/O will block.
	// See fcntl(2) ("man 2 fcntl") for details.
	
	if (fcntl(fileDescriptor, F_SETFL, 0) == -1) {
		NSLog(@"Error clearing O_NONBLOCK %s - %s(%d).\n", port, strerror(errno), errno);
		goto error;
	}
	
	// Get the current options and save them so we can restore the default settings later.
	if (tcgetattr(fileDescriptor, &gOriginalTTYAttrs) == -1) {
		NSLog(@"Error getting tty attributes %s - %s(%d).\n", port, strerror(errno), errno);
		goto error;
	}
	
	// The serial port attributes such as timeouts and baud rate are set by modifying the termios
	// structure and then calling tcsetattr() to cause the changes to take effect. Note that the
	// changes will not become effective without the tcsetattr() call.
	// See tcsetattr(4) ("man 4 tcsetattr") for details.
	
	options = gOriginalTTYAttrs;
	
	// Print the current input and output baud rates.
	// See tcsetattr(4) ("man 4 tcsetattr") for details.
	
	//printf("Current input baud rate is %d\n", (int) cfgetispeed(&options));
	//printf("Current output baud rate is %d\n", (int) cfgetospeed(&options));
	
	// Set raw input (non-canonical) mode, with reads blocking until either a single character
	// has been received or a one second timeout expires.
	// See tcsetattr(4) ("man 4 tcsetattr") and termios(4) ("man 4 termios") for details.
	
	cfmakeraw(&options);
	options.c_cc[VMIN] = 1;
	options.c_cc[VTIME] = 5;
	
	// The baud rate, word length, and handshake options can be set as follows:
	
	cfsetspeed(&options, s); // Set 19200 baud
	options.c_cflag |= (CS8); // RTS flow control of input
	
	
	//printf("Input baud rate changed to %d\n", (int) cfgetispeed(&options));
	//printf("Output baud rate changed to %d\n", (int) cfgetospeed(&options));
	
	// Cause the new options to take effect immediately.
	if (tcsetattr(fileDescriptor, TCSANOW, &options) == -1) {
		NSLog(@"Error setting tty attributes %s - %s(%d).\n", port, strerror(errno), errno);
		goto error;
	}
	// Success
	
	return fileDescriptor;
	
	// Failure "/dev/tty.iap"
error: 
	if (fileDescriptor != -1) {
		close(fileDescriptor);
	}
	return -1;
}
- (void)changeSerialSpeed:(speed_t)s {
	struct termios options;
	struct termios gOriginalTTYAttrs;
	if(serialHandle<0) return;
	// Get the current options and save them so we can restore the default settings later.
	if (tcgetattr(serialHandle, &gOriginalTTYAttrs) == -1) {
		NSLog(@"Error getting tty attributes %s(%d).\n", strerror(errno), errno);
		return;
	}
	
	// The serial port attributes such as timeouts and baud rate are set by modifying the termios
	// structure and then calling tcsetattr() to cause the changes to take effect. Note that the
	// changes will not become effective without the tcsetattr() call.
	// See tcsetattr(4) ("man 4 tcsetattr") for details.
	
	options = gOriginalTTYAttrs;
	
	// Print the current input and output baud rates.
	// See tcsetattr(4) ("man 4 tcsetattr") for details.
	
	//printf("Current input baud rate is %d\n", (int) cfgetispeed(&options));
	//printf("Current output baud rate is %d\n", (int) cfgetospeed(&options));
	
	// Set raw input (non-canonical) mode, with reads blocking until either a single character
	// has been received or a one second timeout expires.
	// See tcsetattr(4) ("man 4 tcsetattr") and termios(4) ("man 4 termios") for details.
	
	cfmakeraw(&options);
	options.c_cc[VMIN] = 1;
	options.c_cc[VTIME] = 5;
	
	// The baud rate, word length, and handshake options can be set as follows:
	
	cfsetspeed(&options, s); // Set 19200 baud
	options.c_cflag |= (CS8); // RTS flow control of input
	
	
	//printf("Input baud rate changed to %d\n", (int) cfgetispeed(&options));
	//printf("Output baud rate changed to %d\n", (int) cfgetospeed(&options));
	
	// Cause the new options to take effect immediately.
	if (tcsetattr(serialHandle, TCSANOW, &options) == -1) {
		NSLog(@"Error setting tty attributes %s(%d).\n", strerror(errno), errno);
		return;
	}
	
}
-(BOOL)sendCommand:(const char*)cmd {
	if(![self checkSerialPort]) {
		return NO;
	}
	if(write(serialHandle,cmd,strlen(cmd))>0)
		return YES;
	else
		return NO;
}	

-(void)startDebug {
	if(debug)return;
	fserial=fopen("/tmp/serial.dat","w");
	fmsg=fopen("/tmp/message.dat","w");
	debug=YES;
}
-(void)stopDebug {
	debug=NO;
	fclose(fserial);
	fclose(fmsg);
}

- (BOOL)EnableGPS {
	isEnabled=YES;
	return YES;
}
-(void)resetGPS {
	
}
- (BOOL)DisableGPS {
	isEnabled=NO;
	return YES;
}
-(NSString*)name {
	return @"Invalid";
}
-(int)refreshRate {
	return 1;
}
- (id)initWithDelegate:(id)del {
	if((self=[super init])) {
		delegate=del;
		stopGPSSerial=NO;
		isConnected=NO;
		isEnabled=NO;
		validLicense=NO;
		started=NO;
		//[self startDebug];
		serial=[[NSString alloc] init];
		if(self.needSerial) {
			if(serialHandle<0) {
				serialHandle=[self _openSerialPort:GPSPORT speed:B19200];
				if(serialHandle<0) {
					NSLog(@"Unable to open the serial port");
					if(![self hasAlreadyShownSerialError]) {
#ifdef USE_UI
						UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error title") message:NSLocalizedString(@"Unable to open the serial port. Make sure that no other GPS software is running in background.",@"GPS serial port error") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss") otherButtonTitles:nil];
						[alert show];
#endif
						[self setHasAlreadyShownSerialError];
					}
					return self;
				}
			}
		}
	}
	return self;
}
-(BOOL)needLicense {
	return NO;
}
-(BOOL) needSerial {
	return YES;
}
-(NSString*)downloadPage:(NSString*)url {
	NSURL *imageURL = [NSURL URLWithString:url];
	return [NSString stringWithContentsOfURL:imageURL];	
}
-(BOOL)checkLicense:(NSString*)s {
	return YES;
}
-(int)getGPSSignalQuality {
	return 0;
}
- (void)stop {
	stopGPSSerial=YES;
	started=NO;
	sleep(1);
}
-(void)dealloc {
	//[self stopDebug];
	[serial release];
	[super dealloc];
}
-(BOOL)GetVersion {
	return YES;
}
- (BOOL)checkSerialPort {
	return (serialHandle<0) || !self.needSerial ? NO : YES;
}
- (BOOL)GetSerial {
	return YES;
}
@end
