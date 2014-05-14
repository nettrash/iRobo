//
//  CardCellView_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 05.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardCellView_iPhone.h"
#import "NSNumber+Currency.h"
#import "NSNumber+MonthNames.h"

@implementation CardCellView_iPhone

@synthesize lblTitle = _lblTitle;
@synthesize lblDetails = _lblDetails;
@synthesize aiActive = _aiActive;

- (void)applyCard:(svcCard *)card
{
    self.lblTitle.text = [NSString stringWithFormat:@"%@ %@/%i", card.card_Number, [[NSNumber numberWithInteger:card.card_Month] monthName], card.card_Year];
    if (card.card_IsOCEAN)
    {
        if ([card.card_Balance isEqualToNumber:[NSNumber numberWithInt:-1]])
        {
            self.lblDetails.text = NSLocalizedString(@"REFRESH_BALANCE_ERROR", @"REFRESH_BALANCE_ERROR");
        }
        else
        {
            self.lblDetails.text = [card.card_Balance numberWithCurrency];
        }
    }
    else
        self.lblDetails.text = card.card_Name;
    
    if (card.card_Approved)
    {
        [self.lblTitle setTextColor:[UIColor darkGrayColor]];
        [self.lblDetails setTextColor:[UIColor darkGrayColor]];
    }
    else
    {
        self.lblDetails.text = NSLocalizedString(@"CardDetail_NeedToAuthorize", @"CardDetail_NeedToAuthorize");
        [self.lblTitle setTextColor:[UIColor grayColor]];
        [self.lblDetails setTextColor:[UIColor grayColor]];
    }
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)startActive
{
    [self.aiActive startAnimating];
}

- (void)stopActive
{
    [self.aiActive stopAnimating];
}

@end
