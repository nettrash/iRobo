//
//  ActivityProtocols.h
//  iRobo
//
//  Created by Ivan Alekseev on 18.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//
#import "svcCard.h"

#ifndef iRobo_ActivityProtocols_h
#define iRobo_ActivityProtocols_h

@protocol CardMoneySendActivityViewControllerDelegate

- (void)sendMoneyActivityFinished:(UIViewController *)controller;

@end

@protocol ActivityResultDelegate

- (void)activityStart:(svcCard *)card;
- (void)activityEnd:(svcCard *)card;

@end

#endif
