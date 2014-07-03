//
//  HistoryBlankActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 03.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "HistoryBlankActivity.h"

@implementation HistoryBlankActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return @"ru.robokassa.history.blank";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_History_Blank_Title", @"Activity_History_Blank_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"HistoryBlankActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"HistoryBlankActivityMiniIcon.png"];
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
    
    if (![op.process isEqualToString:@"Done"])
        return NO;
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //Готовим отображение согласно данным
    self.operation = (svcHistoryOperation *)[activityItems objectAtIndex:0];
}

- (void)performActivity
{
    //Исполняем действие
    if ([(id)self.resultDelegate respondsToSelector:@selector(doActivityParentAction:withData:)]) {
        [self.resultDelegate doActivityParentAction:self withData:self.operation];
    }
    [self activityDidFinish:YES];
}
/*
- (UIViewController *)activityViewController
{
}*/

#pragma mark PayViewControllerDelegate

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
