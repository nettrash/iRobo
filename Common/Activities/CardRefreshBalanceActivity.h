//
//  CardRefreshBalanceActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcCard.h"
#import "UICardActivity.h"

@interface CardRefreshBalanceActivity : UICardActivity

@property (nonatomic, retain) svcCard *card;
@property (nonatomic, retain) UITableViewController *tblCards;

@end
