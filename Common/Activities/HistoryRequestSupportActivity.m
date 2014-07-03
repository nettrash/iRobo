//
//  HistoryRequestSupportActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 01.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "HistoryRequestSupportActivity.h"
#import "RequestSupportViewController_iPhone.h"

@implementation HistoryRequestSupportActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return @"ru.robokassa.history.support";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_History_RequestSupport_Title", @"Activity_History_RequestSupport_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"HistoryRequestSupportActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"HistoryRequestSupportActivityMiniIcon.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if ([activityItems count] == 0) return NO;
    NSObject *item = [activityItems objectAtIndex:0];
    if (![item isKindOfClass:[svcHistoryOperation class]]) {
        return NO;
    }
    svcHistoryOperation *op = (svcHistoryOperation *)item;
    
    if (!op.op_Key || op.op_Key == nil || [op.op_Key isEqualToString:@""]) {
        return NO;
    }
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
 [self activityDidFinish:YES];
 }*/

- (UIViewController *)activityViewController
{
    //Возвращаем конторллер отображения для действия
    RequestSupportViewController_iPhone *rs = [[RequestSupportViewController_iPhone alloc] initWithNibName:@"RequestSupportViewController_iPhone" bundle:nil andHistoryOperation:self.operation];
    rs.delegate = self;
    return rs;
}

#pragma mark RequestSupportDelegate

- (void)requestSupportFinished:(UIViewController *)controller
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
