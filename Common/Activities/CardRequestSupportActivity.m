//
//  CardRequestSupportActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardRequestSupportActivity.h"
#import "svcCard.h"

@implementation CardRequestSupportActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return @"ru.robokassa.card.support";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_Card_RequestSupport_Title", @"Activity_Card_RequestSupport_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"CardRequestSupportActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"CardRequestSupportActivityMiniIcon.png"];
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
    if (![MFMailComposeViewController canSendMail]) {
        return NO;
    }
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //Готовим отображение согласно данным
}

/*- (void)performActivity
{
    //Исполняем действие
    [self activityDidFinish:YES];
}*/

- (UIViewController *)activityViewController
{
    //Возвращаем конторллер отображения для действия
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    
    [mailController setSubject:NSLocalizedString(@"MailSubject_OceanSupport", @"MailSubject_OceanSupport")];
    [mailController setMessageBody:NSLocalizedString(@"MailBody_OceanSupport", @"MailBody_OceanSupport") isHTML:YES];
    [mailController setToRecipients:[NSArray arrayWithObject:@"help@oceanbank.ru"]];
    
    mailController.mailComposeDelegate = self;
    
    return mailController;
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
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
