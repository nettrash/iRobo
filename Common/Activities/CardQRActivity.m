//
//  CardQRActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 14.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardQRActivity.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"

@implementation CardQRActivity

@synthesize card = _card;
@synthesize tblCards = _tblCards;

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return @"ru.robokassa.card.qr";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_Card_QR_Title", @"Activity_Card_QR_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"CardQRActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"CardQRActivityMiniIcon.png"];
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
    if ([activityItems count] > 1)
        self.tblCards = (UITableViewController *)[activityItems objectAtIndex:1];
}

- (void)performActivity
{
    [self.resultDelegate doActivityParentAction:self withData:self.card];
    [self activityDidFinish:YES];
}

/*
 - (UIViewController *)activityViewController
 {
 //Возвращаем конторллер отображения для действия
 return nil;
 }*/

@end
