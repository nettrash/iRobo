//
//  HistoryRemoveFromFavoriteActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 04.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UIHistoryActivity.h"
#import "svcHistoryOperation.h"

@interface HistoryRemoveFromFavoriteActivity : UIHistoryActivity

@property (nonatomic, retain) svcHistoryOperation *operation;

@end
