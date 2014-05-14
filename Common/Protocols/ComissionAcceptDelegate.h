//
//  ComissionAcceptDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 05.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_ComissionAcceptDelegate_h
#define iRobo_ComissionAcceptDelegate_h

@protocol ComissionAcceptDelegate

- (void)acceptingComissionFinished:(UIViewController *)controller withResult:(BOOL)result;

@end

#endif
