//
//  CardMoneySendActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardMoneySendActivityViewController_iPhone.h"
#import "svcCard.h"
#import "ActivityProtocols.h"
#import "UICardActivity.h"

@interface CardMoneySendActivity : UICardActivity <CardMoneySendActivityViewControllerDelegate>

@property (nonatomic, retain) svcCard *card;

@end
