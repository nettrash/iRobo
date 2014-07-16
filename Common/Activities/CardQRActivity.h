//
//  CardQRActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 14.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UICardActivity.h"

@interface CardQRActivity : UICardActivity

@property (nonatomic, retain) svcCard *card;
@property (nonatomic, retain) UITableViewController *tblCards;

@end
