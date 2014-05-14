//
//  ScanViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 14.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXingObjC.h"
#import "ScanViewControllerDelegate.h"

@interface ScanViewController_iPhone : UIViewController <ZXCaptureDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<ScanViewControllerDelegate>)delegate;

@end
