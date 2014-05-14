//
//  CardsViewControllerDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 21.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_CardsViewControllerDelegate_h
#define iRobo_CardsViewControllerDelegate_h

#import "svcCard.h"

@protocol CardsViewControllerDelegate

@optional

- (void)cardSelected:(svcCard *)card controller:(UIViewController *)controller;

@end

#endif
