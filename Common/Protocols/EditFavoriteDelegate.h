//
//  EditFavoriteDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 04.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#ifndef iRobo_EditFavoriteDelegate_h
#define iRobo_EditFavoriteDelegate_h

#import "svcFavorite.h"

@protocol EditFavoriteDelegate

- (void)editFavorite:(UIViewController *)controller favorite:(svcFavorite *)favorite;
- (void)cancelEditFavorite:(UIViewController *)controller;

@end

#endif