//
//  CardReceiveMoneyActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardReceiveMoneyActivity.h"
#import "Enums.h"

@implementation CardReceiveMoneyActivity

@synthesize card = _card;
@synthesize cards = _cards;

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return @"ru.robokassa.card.receivemoney";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_Card_ReceiveMoney_Title", @"Activity_Card_ReceiveMoney_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"CardReceiveMoneyActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"CardReceiveMoneyActivityMiniIcon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([activityItems count] == 0) return NO;
    NSObject *item = [activityItems objectAtIndex:0];
    if (![item isKindOfClass:[svcCard class]]) {
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
    if ([activityItems count] > 3)
        self.cards = (NSMutableArray *)[activityItems objectAtIndex:3];
}
/*
- (void)performActivity
{
    //Исполняем действие
    [self activityDidFinish:YES];
}
*/
- (UIViewController *)activityViewController
{
    [self.resultDelegate activityStart:self.card];
    CardMoneySendActivityViewController_iPhone *vc = [[CardMoneySendActivityViewController_iPhone alloc] initWithNibName:@"CardMoneySendActivityViewController_iPhone" bundle:nil formType:MoneySendFormTypeTransferBetween];
    vc.delegate = self;
    vc.card = self.card;
    vc.cards = self.cards;
    return vc;
}

#pragma mark CardMoneySendActivityViewControllerDelegate

- (void)sendMoneyActivityFinished:(UIViewController *)controller
{
    [self.resultDelegate activityEnd:self.card];
    if (self.performByButton)
    {
        [self activityDidFinishByButton];
    }
    else
    {
        [self activityDidFinish:YES];
    }
}

@end
