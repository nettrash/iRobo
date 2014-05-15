//
//  ScanViewControllerDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 14.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#ifndef iRobo_ScanViewControllerDelegate_h
#define iRobo_ScanViewControllerDelegate_h

@protocol ScanViewControllerDelegate

- (void)scanResult:(UIViewController *)controller success:(BOOL)success result:(AVMetadataMachineReadableCodeObject *)result;

@end

#endif
