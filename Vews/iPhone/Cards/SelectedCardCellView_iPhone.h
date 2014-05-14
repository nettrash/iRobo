//
//  SelectedCardCellView_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 05.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcCard.h"

@interface SelectedCardCellView_iPhone : UITableViewCell


@property (nonatomic, retain) NSArray *activityData;
@property (nonatomic, retain) NSMutableArray *availibleActivities;
@property (nonatomic, retain) svcCard *card;
@property (nonatomic, retain) IBOutlet UILabel *lblTitle;
@property (nonatomic, retain) IBOutlet UILabel *lblDetails;
@property (nonatomic, retain) IBOutlet UIScrollView *svActivities;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *aiActive;

- (void)applyCard:(NSArray *)data withActivities:(NSArray *)activities;
- (void)startActive;
- (void)stopActive;

@end
