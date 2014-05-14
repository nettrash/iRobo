//
//  CardMoneySendActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardMoneySendActivity.h"
#import "Enums.h"

@implementation CardMoneySendActivity

@synthesize card = _card;

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return @"ru.robokassa.card.moneysend";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_Card_MoneySend_Title", @"Activity_Card_MoneySend_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"CardMoneySendActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"CardMoneySendActivityMiniIcon.png"];
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
    if ([(svcCard *)item card_IsOCEAN] && [[(svcCard *)item card_Balance] doubleValue] < 51)
        return NO;
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //Готовим отображение согласно данным
    self.card = (svcCard *)[activityItems objectAtIndex:0];
}
/*
- (void)performActivity
{
    //Исполняем действие
    [self activityDidFinish:YES];
}*/

- (UIViewController *)activityViewController
{
    [self.resultDelegate activityStart:self.card];
    //Возвращаем конторллер отображения для действия
    CardMoneySendActivityViewController_iPhone *vc = [[CardMoneySendActivityViewController_iPhone alloc] initWithNibName:@"CardMoneySendActivityViewController_iPhone" bundle:nil formType:MoneySendFormTypeSendOutside];
    vc.delegate = self;
    vc.card = self.card;
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
