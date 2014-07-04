//
//  AddToFavoriteDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 04.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_AddToFavoriteDelegate_h
#define iRobo_AddToFavoriteDelegate_h

#import "svcHistoryOperation.h"

@protocol AddToFavoriteDelegate

- (void)addToFavorite:(UIViewController *)controller operation:(svcHistoryOperation *)op withName:(NSString*)name andSumm:(NSDecimalNumber *)summa;
- (void)cancelAddToFavorite:(UIViewController *)controller;

@end

#endif