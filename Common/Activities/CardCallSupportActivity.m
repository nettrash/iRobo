//
//  CardCallSupportActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardCallSupportActivity.h"
#import "svcCard.h"

@implementation CardCallSupportActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return @"ru.robokassa.card.support";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_Card_CallSupport_Title", @"Activity_Card_CallSupport_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"CardCallSupportActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"CardCallSupportActivityMiniIcon.png"];
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
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
        return NO;
    }
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //Готовим отображение согласно данным
}

- (void)performActivity
{
    //Исполняем действие
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:+74959815500"]]];
    [self activityDidFinish:YES];
}
/*
 - (UIViewController *)activityViewController
 {
 //Возвращаем конторллер отображения для действия
 return nil;
 }*/

@end
