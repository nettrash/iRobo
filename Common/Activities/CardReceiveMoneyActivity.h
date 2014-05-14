//
//  CardReceiveMoneyActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcCard.h"
#import "CardMoneySendActivityViewController_iPhone.h"
#import "ActivityProtocols.h"
#import "UICardActivity.h"

@interface CardReceiveMoneyActivity : UICardActivity <CardMoneySendActivityViewControllerDelegate>

@property (nonatomic, retain) svcCard *card;
@property (nonatomic, retain) NSMutableArray *cards;

@end
