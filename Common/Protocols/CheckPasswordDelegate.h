//
//  CheckPasswordDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 14.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_CheckPasswordDelegate_h
#define iRobo_CheckPasswordDelegate_h

@protocol CheckPasswordDelegate

- (void)passwordChecked:(UIViewController *)controller withResult:(BOOL)result;

@end

#endif
