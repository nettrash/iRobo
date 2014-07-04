//
//  HistoryCellView_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 27.06.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "HistoryCellView_iPhone.h"
#import "NSNumber+Currency.h"
#import "NSDate+Operation.h"

@interface HistoryCellView_iPhone ()

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *currencyImage;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *summLabel;
@property (nonatomic, retain) IBOutlet UILabel *lblResult;

@end

@implementation HistoryCellView_iPhone

@synthesize operation = _operation;
@synthesize imageView = _imageView;
@synthesize currencyImage = _currencyImage;
@synthesize titleLabel = _titleLabel;
@synthesize dateLabel = _dateLabel;
@synthesize summLabel = _summLabel;
@synthesize lblResult = _lblResult;

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellData:(svcHistoryOperation *)op
{
    self.operation = op;
    NSString *title = op.currName;
    if (op.inFavorites && op.favoriteName && op.favoriteName != nil && ![op.favoriteName isEqualToString:@""])
        title = op.favoriteName;
    if (op.check_Id > 0)
        title = [NSString stringWithFormat:@"%@ N-%@", op.check_MerchantName, op.check_MerchantOrder];
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
}

@end
