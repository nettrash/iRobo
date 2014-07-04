//
//  HistoryRemoveFromFavoriteActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 04.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "HistoryRemoveFromFavoriteActivity.h"

@implementation HistoryRemoveFromFavoriteActivity
+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return @"ru.robokassa.history.favorites.remove";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_History_RemoveFromFavorites_Title", @"Activity_History_RemoveFromFavorites_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"HistoryRemoveFromFavoritesActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"HistoryRemoveFromFavoritesActivityMiniIcon.png"];
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
    
    if (op.check_Id > 0 || op.charity_Id > 0)
        return NO;

    if (!op.inFavorites)
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