//
//  NetworkReceiverViewController.h
//  xGPS
//
//  Created by Mathieu on 10/8/08.
//  Copyright 2008 Xwaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransferController.h"

@interface NetworkReceiverViewController : UIViewController<TransferControllerDelegate> {
	UILabel *lblStatus;
	UIActivityIndicatorView *progress;
}

@end
