//
//  EnterCVCDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 18.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_EnterCVCDelegate_h
#define iRobo_EnterCVCDelegate_h


@protocol EnterCVCDelegate

@required

- (void)finishEnterCVC:(UIViewController *)controller cvcEntered:(BOOL)cvcEntered cvcValue:(NSString*)cvcValue;
- (void)cancelEnterCVC:(UIViewController *)controller;

@end

#endif
