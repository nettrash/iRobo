//
//  CardAuthorizeViewControllerDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 18.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_CardAuthorizeViewControllerDelegate_h
#define iRobo_CardAuthorizeViewControllerDelegate_h

@protocol CardAuthorizeViewControllerDelegate

@optional

- (void)finishAuthorizeAction:(UIViewController *)controller;

@end

#endif
