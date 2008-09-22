//
//  GeoEncoder.h
//  xGPS
//
//  Created by Mathieu on 9/22/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GeoEncoderDelegate
-(void)geoEncodeGot:(NSDictionary*)result forRequest:(NSString*)req;

@end


@interface GeoEncoder : NSObject {
	NSString *req;
	id delegate;
	NSMutableDictionary* result;
	NSString *currentPlacename;
	NSString *currentPos;
	BOOL parsingPlace;
	NSString *currentProp;
}
@property (nonatomic,assign) id delegate;
-(BOOL)geoencode:(NSString*)toEncode;
@end
