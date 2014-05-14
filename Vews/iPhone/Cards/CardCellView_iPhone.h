//
//  CardCellView_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 05.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcCard.h"

@interface CardCellView_iPhone : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *lblTitle;
@property (nonatomic, retain) IBOutlet UILabel *lblDetails;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *aiActive;

- (void)applyCard:(svcCard *)card;
- (void)startActive;
- (void)stopActive;

@end
