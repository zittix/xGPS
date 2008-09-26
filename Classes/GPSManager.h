//
//  GPSManager.h
//  xGPS
//
//  Created by Mathieu on 9/15/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPSController.h"
#define xGPS_ID	1
#define iGPSD_ID 3
#define FakeGPS_ID 4
#define iPhone3G_ID 2
#define NBGPS 4
@interface GPSManager : NSObject<UpdateProtocol> {
	GPSController* gpsControllers1;
	GPSController* gpsControllers2;
	GPSController* gpsControllers3;
	GPSController* gpsControllers4;
	int idGPS;
	id delegate;
	
}
- (void)gpsChanged:(ChangedState*)msg;
-(GPSController*)GetGPSWithId:(int)_id;
-(void)setCurrentGPS:(int)id;
-(GPSController*)GetCurrentGPS;
-(NSString*)GetCurrentGPSName;
-(NSDictionary*)GetAllGPSNames;
-(NSString*)GetGPSName:(int)id;
-(void)setDelegate:(id)del;
@property(readonly) int idGPS;
@end
