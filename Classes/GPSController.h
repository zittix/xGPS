//
//  GPSController.h
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangedState.h"
#import "gps.h"
#include <termios.h> /* POSIX terminal control definitions */
@protocol UpdateProtocol
- (void)gpsChanged:(ChangedState*)msg;
@end
void writeDebugSerial(const char*msg,int len);
void writeDebugMessage(const char*msg);
@interface GPSController : NSObject {
	id delegate;
	
	bool stopGPSSerial;
	int version_major;
	int version_minor;
	BOOL isConnected;
	struct gps_data_t gps_data;
	BOOL isEnabled;
	NSString* serial;
	BOOL debug;	
	NSString *license;
	BOOL validLicense;
	BOOL started;
}
- (int)_openSerialPort:(const char*)port speed:(speed_t)s;
- (void)changeSerialSpeed:(speed_t)s;
- (void)startDebug;
- (void)stopDebug;
-(void)resetGPS;
-(int)serialHandle;
- (BOOL)GetVersion;
-(BOOL)hasAlreadyShownSerialError;
-(void)setHasAlreadyShownSerialError;
- (BOOL)GetSerial;
- (BOOL)sendCommand:(const char*)cmd;
- (BOOL)EnableGPS;
- (BOOL)DisableGPS;
- (void)stop;
-(void)start;
- (id)initWithDelegate:(id)del;
- (BOOL)checkSerialPort;
-(NSString*)name;
-(BOOL)needLicense;
-(BOOL)checkLicense:(NSString*)s;
-(NSString*)downloadPage:(NSString*)url;
@property(retain,nonatomic) id delegate;
@property(retain,nonatomic) NSString* serial;
@property(nonatomic) int version_major;
@property(nonatomic) int version_minor;
@property(nonatomic) BOOL isConnected;
@property(nonatomic,readonly) BOOL debug;
@property(nonatomic) BOOL isEnabled;
@property(nonatomic) struct gps_data_t gps_data;
@property(readonly) BOOL validLicense;
@property(readonly) BOOL started;
@property(readonly) NSString* license;
@end
