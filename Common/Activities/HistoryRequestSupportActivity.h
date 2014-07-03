//
//  HistoryRequestSupportActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 01.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UIHistoryActivity.h"
#import "svcHistoryOperation.h"
#import "RequestSupportDelegate.h"

@interface HistoryRequestSupportActivity : UIHistoryActivity <RequestSupportDelegate>

@property (nonatomic, retain) svcHistoryOperation *operation;

@end
