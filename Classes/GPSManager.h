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
#define FakeGPS_ID 6
#define iPhone3G_ID 2
#define iGPS360_ID 4
#define GFi_ID 5
#define NBGPS 6
@interface GPSManager : NSObject<UpdateProtocol> {
	GPSController* gpsControllers1;
	GPSController* gpsControllers2;
	GPSController* gpsControllers3;
	GPSController* gpsControllers4;
	GPSController* gpsControllers5;
	GPSController* gpsControllers6;
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
@property(readonly,nonatomic,getter=GetCurrentGPS) GPSController* currentGPS;
@end
