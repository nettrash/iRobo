//
//  SelectedHistoryCellView_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 01.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcHistoryOperation.h"

@interface SelectedHistoryCellView_iPhone : UITableViewCell

@property (nonatomic, retain) svcHistoryOperation *operation;
@property (nonatomic, retain) NSMutableArray *availibleActivities;

- (void)setCellData:(svcHistoryOperation *)op withActivities:(NSArray *)activities;

@end
