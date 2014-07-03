//
//  HistoryRepeatPaymentActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 01.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UIHistoryActivity.h"
#import "PayViewControllerDelegate.h"
#import "svcHistoryOperation.h"

@interface HistoryRepeatPaymentActivity : UIHistoryActivity <PayViewControllerDelegate>

@property (nonatomic, retain) svcHistoryOperation *operation;

@end
