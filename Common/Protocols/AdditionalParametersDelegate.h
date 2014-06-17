//
//  AdditionalParametersDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 20.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_AdditionalParametersDelegate_h
#define iRobo_AdditionalParametersDelegate_h

@protocol AdditionalParametersDelegate

- (void)parametersEntered:(UIViewController *)controller parameters:(NSArray *)parameters;
- (void)userCancelAction:(UIViewController *)controller;

@end

#endif
