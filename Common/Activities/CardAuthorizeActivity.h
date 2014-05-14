//
//  CardAuthorizeActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 21.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcCard.h"
#import "CardAuthorizeViewControllerDelegate.h"
#import "ActivityAction.h"
#import "UICardActivity.h"

@interface CardAuthorizeActivity : UICardActivity <CardAuthorizeViewControllerDelegate>

@property (nonatomic, retain) svcCard *card;
@property (nonatomic, retain) UITableViewController *tblCards;
@property (nonatomic, retain) ActivityAction *action;

@end
