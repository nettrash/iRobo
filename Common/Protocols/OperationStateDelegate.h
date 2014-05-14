//
//  OperationStateDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 28.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_OperationStateDelegate_h
#define iRobo_OperationStateDelegate_h

@protocol OperationStateDelegate

- (void)operationIsComplete:(UIViewController *)controller success:(BOOL)success;

@end

#endif
