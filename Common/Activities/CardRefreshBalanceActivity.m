//
//  CardRefreshBalanceActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardRefreshBalanceActivity.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"

@implementation CardRefreshBalanceActivity

@synthesize card = _card;
@synthesize tblCards = _tblCards;

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return @"ru.robokassa.card.balance";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_Card_Balance_Title", @"Activity_Card_Balance_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"CardRefreshBalanceActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"CardRefreshBalanceActivityMiniIcon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([activityItems count] == 0) return NO;
    NSObject *item = [activityItems objectAtIndex:0];
    if (![item isKindOfClass:[svcCard class]]) {
        return NO;
    }
    if (![(svcCard *)item card_IsOCEAN]) {
        return NO;
    }
    if (![(svcCard *)item card_Approved]) {
        return NO;
    }
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //Готовим отображение согласно данным
    self.card = (svcCard *)[activityItems objectAtIndex:0];
    if ([activityItems count] > 1)
        self.tblCards = (UITableViewController *)[activityItems objectAtIndex:1];
}

- (void)performActivity
{
    [self.resultDelegate activityStart:self.card];
    //Исполняем действие
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetCard:self action:@selector(getCardHandler:) UNIQUE:[app.userProfile uid] cardId:self.card.card_Id];
    [self activityDidFinish:YES];
}

- (void)getCardHandler:(id)response
{
    [self.resultDelegate activityEnd:self.card];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            self.card.card_Balance = [(svcCard *)[resp.cards objectAtIndex:0] card_Balance];
            [self.tblCards.tableView reloadData];
        }
    }
}

/*
- (UIViewController *)activityViewController
{
    //Возвращаем конторллер отображения для действия
    return nil;
}*/

@end
