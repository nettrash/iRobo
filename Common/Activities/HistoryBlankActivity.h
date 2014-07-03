//
//  HistoryBlankActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 03.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UIHistoryActivity.h"
#import "svcHistoryOperation.h"

@interface HistoryBlankActivity : UIHistoryActivity

@property (nonatomic, retain) svcHistoryOperation *operation;

@end
