//
//  HistoryCellView_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 27.06.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcHistoryOperation.h"

@interface HistoryCellView_iPhone : UITableViewCell

@property (nonatomic, retain) svcHistoryOperation *operation;

- (void)setCellData:(svcHistoryOperation *)op;

@end
