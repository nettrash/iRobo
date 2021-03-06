//
//  SelectedHistoryCellView_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 01.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "SelectedHistoryCellView_iPhone.h"
#import "NSNumber+Currency.h"
#import "UIHistoryActivity.h"
#import "NSDate+Operation.h"

@interface SelectedHistoryCellView_iPhone ()

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *currencyImage;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *summLabel;
@property (nonatomic, retain) IBOutlet UILabel *lblResult;
@property (nonatomic, retain) IBOutlet UIScrollView *svActivities;
@property (nonatomic, retain) IBOutlet UILabel *lblData;

@end

@implementation SelectedHistoryCellView_iPhone

@synthesize operation = _operation;
@synthesize imageView = _imageView;
@synthesize currencyImage = _currencyImage;
@synthesize titleLabel = _titleLabel;
@synthesize dateLabel = _dateLabel;
@synthesize summLabel = _summLabel;
@synthesize lblResult = _lblResult;
@synthesize svActivities = _svActivities;
@synthesize availibleActivities = _availibleActivities;
@synthesize lblData = _lblData;

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (NSInteger)monthsBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSMonthCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference month];
}

- (NSInteger)yearsBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSYearCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSYearCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSYearCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference year];
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

- (void)setCellData:(svcHistoryOperation *)op withActivities:(NSArray *)activities
{
    self.availibleActivities = [NSMutableArray arrayWithCapacity:0];
    for (UIHistoryActivity *a in activities)
    {
        NSArray *ad = [NSMutableArray arrayWithObjects:op, nil];
        if ([a canPerformWithActivityItems:ad])
        {
            [a prepareWithActivityItems:ad];
            [self.availibleActivities addObject:a];
        }
    }

    self.operation = op;
    
    NSString *title = op.currName;
    if (op.inFavorites && op.favoriteName && op.favoriteName != nil && ![op.favoriteName isEqualToString:@""])
        title = op.favoriteName;
    if (op.check_Id > 0)
        title = [NSString stringWithFormat:@"%@", op.check_MerchantName];
    if (op.charity_Id > 0)
        title = op.charity_Name;
    if ([title hasPrefix:@"RUR "]) {
        title = [title substringFromIndex:4];
    }
    self.titleLabel.text = title;
    self.summLabel.text = [op.op_Sum numberWithCurrency];
    self.imageView.image = [UIImage imageNamed:@"Information"];
    self.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:250.0/255.0 alpha:1.0];
    self.lblResult.text = NSLocalizedString(@"OpInProgress", @"OpInProgress");
    if ([op.process isEqualToString:@"Done"]) {
        self.imageView.image = [UIImage imageNamed:op.inFavorites ? @"FavoriteSuccess" : @"Success"];
        self.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:255.0/255.0 blue:250.0/255.0 alpha:1.0];
        self.lblResult.text = NSLocalizedString(@"OpDone", @"OpDone");
    }
    if ([op.process isEqualToString:@"Cancel"]) {
        self.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
        self.imageView.image = [UIImage imageNamed:op.inFavorites ? @"FavoriteFail" : @"Fail"];
        self.lblResult.text = NSLocalizedString(@"OpCancel", @"OpCancel");
    }
    
    if (op.check_Id > 0)
        self.currencyImage.image = [UIImage imageNamed:@"MainCheckIcon.png"];
    else {
        if (op.charity_Id > 0) {
            self.currencyImage.image = [UIImage imageNamed:@"MainCharityIcon.png"];
        } else {
            self.currencyImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", op.out_curr]];
            if (self.currencyImage.image == nil)
                self.currencyImage.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];
        }
    }
    
    self.dateLabel.text = [op.op_RegDate operationDate];
    
    NSString *prms = @"";
    if (op.charity_Id > 0)
    {
        prms = [NSString stringWithFormat:@"Доброе дело №%i", op.charity_Id];
    }
    else
    {
        if (op.check_Id > 0)
        {
            prms = [NSString stringWithFormat:@"№ заказа %@", op.check_MerchantOrder];
        }
        else
        {
            if (op.op_Parameters && op.op_Parameters != nil && ![op.op_Parameters isEqualToString:@""])
            {
                NSArray *a = [op.op_Parameters componentsSeparatedByString:@";"];
                NSMutableArray *ap = [NSMutableArray arrayWithCapacity:0];
                for (NSString *s in a)
                {
                    if (s && s != nil && ![s isEqualToString:@""])
                    {
                        NSArray *b = [s componentsSeparatedByString:@":"];
                        if (b && b != nil && [b count] > 1)
                        {
                            [ap addObject:(NSString *)[b objectAtIndex:1]];
                        }
                    }
                }
                prms = [ap componentsJoinedByString:@" "];
            }
        }
    }
    self.lblData.text = prms;

    // Подготовить отображение активностей
    int idx = 0;
    
    for (UIHistoryActivity *a in self.availibleActivities) {
        [self.svActivities addSubview:[a activityButtonWithIndex:idx++]];
    }
    
    CGSize size = self.svActivities.contentSize;
    size.width = 52 * idx;
    self.svActivities.contentSize = size;
}

@end
