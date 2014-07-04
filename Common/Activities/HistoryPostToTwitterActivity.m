//
//  HistoryPostToTwitterActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 03.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "HistoryPostToTwitterActivity.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "NSDate+Operation.h"
#import "NSNumber+Currency.h"

@implementation HistoryPostToTwitterActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return @"ru.robokassa.history.post.twitter";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_History_PostToTwitter_Title", @"Activity_History_PostToTwitter_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"HistoryPostToTwitterActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"HistoryPostToTwitterActivityMiniIcon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([activityItems count] == 0) return NO;
    if ([SLComposeViewController instanceMethodForSelector:@selector(isAvailableForServiceType:)] == nil || ![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        return NO;
    
    NSObject *item = [activityItems objectAtIndex:0];
    if (![item isKindOfClass:[svcHistoryOperation class]]) {
        return NO;
    }
    
    svcHistoryOperation *op = (svcHistoryOperation *)item;
    
    if (!op.op_Key || op.op_Key == nil || [op.op_Key isEqualToString:@""]) {
        return NO;
    }
    
    if (![op.process isEqualToString:@"Done"])
        return NO;
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //Готовим отображение согласно данным
    self.operation = (svcHistoryOperation *)[activityItems objectAtIndex:0];
}

/*- (void)performActivity
 {
 //Исполняем действие
 if ([(id)self.resultDelegate respondsToSelector:@selector(doActivityParentAction:withData:)]) {
 [self.resultDelegate doActivityParentAction:self withData:self.operation];
 }
 [self activityDidFinish:YES];
 }*/

- (UIViewController *)activityViewController
{
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    NSString *textToPost = @"Совершил оплату через приложение ROBOKASSA и остался доволен. Оплачивал Билайн. Все очень удобно.";
    UIImage *imgToPost = [UIImage imageNamed:@"ROBOKASSA.png"];
    NSURL *urlToPost = [NSURL URLWithString:@"http://www.robokassa.ru"];
    
    NSString *dateStr = [[self.operation.op_RegDate operationDate] lowercaseString];
    NSString *agentStr = [self.operation.currName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([agentStr hasPrefix:@"RUR "])
        agentStr = [agentStr substringFromIndex:4];
    NSString *summaStr = [self.operation.op_Sum numberWithCurrency];
    NSString *stateStr = NSLocalizedString(@"OpInProgress", @"OpInProgress");
    
    if ([self.operation.process isEqualToString:@"Done"])
        stateStr = NSLocalizedString(@"OpDone", @"OpDone");
    if ([self.operation.process isEqualToString:@"Cancel"])
        stateStr = NSLocalizedString(@"OpCancel", @"OpCancel");
    
    NSString *template = [NSString stringWithFormat:NSLocalizedString(@"SocialPost_Twitter_ExchangeOperation", @"SocialPost_Twitter_ExchangeOperation"), agentStr];
    if (self.operation.check_Id > 0) {
        template = [NSString stringWithFormat:NSLocalizedString(@"SocialPost_Twitter_ShopOperation", @"SocialPost_Twitter_ShopOperation"), self.operation.check_MerchantName];
        imgToPost = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://misc.roboxchange.com/External/iPhone/MerchantLogo.ashx?checkId=%i", self.operation.check_Id]]]];
        urlToPost = [NSURL URLWithString:[NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://misc.roboxchange.com/External/iPhone/MerchantURL.ashx?checkId=%i", self.operation.check_Id]] encoding:NSUTF8StringEncoding error:nil]];
    }
    if (self.operation.charity_Id > 0) {
        template = [NSString stringWithFormat:NSLocalizedString(@"SocialPost_Twitter_CharityOperation", @"SocialPost_Twitter_CharityOperation"), self.operation.charity_Name];
        NSString *charityURL = [NSString stringWithFormat:@"%@%@%@", @"https://auth.robokassa.ru/Payment/qrcode.ashx?source=https://misc.roboxchange.com/External/iPhone/linktorobokassa.ashx?data=charity%2F%3FCharityID%3D", [NSString stringWithFormat:@"%i", self.operation.charity_Id], @"&backImage=none&size=512"];
        imgToPost = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:charityURL]]];
    }
    
    textToPost = template;
    
    [composeViewController setInitialText:textToPost];
    if (imgToPost)
        [composeViewController addImage:imgToPost];
    if (urlToPost)
        [composeViewController addURL:urlToPost];
    
    [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
        
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                [self finishPost];
                break;
            case SLComposeViewControllerResultDone:
                [self finishPost];
                break;
                
            default:
                break;
        }
        
    }];
    return composeViewController;
}

- (void)finishPost
{
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