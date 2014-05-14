//
//  AddCardDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 21.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_AddCardDelegate_h
#define iRobo_AddCardDelegate_h

@protocol AddCardViewControllerDelegate

- (void)addCardFinished:(UIViewController *)controller withResult:(BOOL)result;

@end

#endif
