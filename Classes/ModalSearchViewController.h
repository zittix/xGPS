//
//  ModalSearchViewController.h
//  xGPS
//
//  Created by Mathieu on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchPlacesView.h"

@interface ModalSearchViewController : UIViewController<SearchPlacesViewDelegate> {
	SearchPlacesView *searchPlacesView;
	id delegate;
}
-(id)initWithDelegate:(id<SearchPlacesViewDelegate>)del;
@property (nonatomic) BOOL location;
@end
