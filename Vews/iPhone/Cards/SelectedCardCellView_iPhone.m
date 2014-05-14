//
//  SelectedCardCellView_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 05.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "SelectedCardCellView_iPhone.h"
#import "NSNumber+Currency.h"
#import "NSNumber+MonthNames.h"
#import "UIImage+Color.h"
#import "UIImage+Scale.h"
#import "UICardActivity.h"

@implementation SelectedCardCellView_iPhone

@synthesize activityData = _activityData;
@synthesize availibleActivities = _availibleActivities;
@synthesize card = _card;
@synthesize lblTitle = _lblTitle;
@synthesize lblDetails = _lblDetails;
@synthesize svActivities = _svActivities;
@synthesize aiActive = _aiActive;

- (void)applyCard:(NSArray *)data withActivities:(NSArray *)activities
{
    self.activityData = data;
    
    self.availibleActivities = [NSMutableArray arrayWithCapacity:0];
    for (UICardActivity *a in activities)
    {
        if ([a canPerformWithActivityItems:self.activityData])
        {
            [a prepareWithActivityItems:self.activityData];
            [self.availibleActivities addObject:a];
        }
    }
    
    self.card = (svcCard *)[data objectAtIndex:0];
    self.lblTitle.text = [NSString stringWithFormat:@"%@ %@/%i", self.card.card_Number, [[NSNumber numberWithInteger:self.card.card_Month] monthName], self.card.card_Year];
    if (self.card.card_IsOCEAN)
    {
        if ([self.card.card_Balance isEqualToNumber:[NSNumber numberWithInt:-1]])
        {
            self.lblDetails.text = NSLocalizedString(@"REFRESH_BALANCE_ERROR", @"REFRESH_BALANCE_ERROR");
        }
        else
        {
            self.lblDetails.text = [self.card.card_Balance numberWithCurrency];
        }
    }
    else
        self.lblDetails.text = self.card.card_Name;
    
    if (self.card.card_Approved)
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
    
    // Подготовить отображение активностей
    int idx = 0;
    
    for (UICardActivity *a in self.availibleActivities) {
        [self.svActivities addSubview:[a activityButtonWithIndex:idx++]];
    }
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
