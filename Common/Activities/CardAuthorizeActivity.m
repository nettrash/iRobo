//
//  CardAuthorizeActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 21.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardAuthorizeActivity.h"
#import "svcCard.h"
#import "CardAuthorizeViewController_iPhone.h"

@implementation CardAuthorizeActivity

@synthesize card = _card;
@synthesize action = _action;

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return @"ru.robokassa.card.authorize";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_Card_Authorize_Title", @"Activity_Card_Authorize_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"CardAuthorizeActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"CardAuthorizeActivityMiniIcon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([activityItems count] == 0) return NO;
    NSObject *item = [activityItems objectAtIndex:0];
    if (![item isKindOfClass:[svcCard class]]) {
        return NO;
    }
    if ([(svcCard *)item card_Approved]) {
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
    if ([activityItems count] > 2)
        self.action = (ActivityAction *)[activityItems objectAtIndex:2];
}

/*- (void)performActivity
{
    //Исполняем действие
    [self activityDidFinish:YES];
}*/

- (UIViewController *)activityViewController
{
    [self.resultDelegate activityStart:self.card];
    //Возвращаем конторллер отображения для действия
    CardAuthorizeViewController_iPhone *c = [[CardAuthorizeViewController_iPhone alloc] initWithNibName:@"CardAuthorizeViewController_iPhone" bundle:nil];
    c.delegate = self;
    c.card_Id = self.card.card_Id;
    c.card_InAuthorize = self.card.card_InAuthorize;
    return c;
}

#pragma mark CardAuthorizeViewControllerDelegate

- (void)finishAuthorizeAction:(UIViewController *)controller
{
    [self.resultDelegate activityEnd:self.card];
    if (self.action != nil)
    {
        [self.tblCards.refreshControl beginRefreshing];
        [self.action.target performSelector:self.action.selector withObject:nil afterDelay:.1];
    }
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
