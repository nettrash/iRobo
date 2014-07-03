//
//  HistoryRepeatPaymentActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 01.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "HistoryRepeatPaymentActivity.h"
#import "svcTopCurrency.h"
#import "PayViewController_iPhone.h"

@implementation HistoryRepeatPaymentActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return @"ru.robokassa.history.repeatpayment";
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Activity_History_RepeatPayment_Title", @"Activity_History_RepeatPayment_Title");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"HistoryRepeatPaymentActivityIcon.png"];
}

- (UIImage *)activityMiniImage
{
    return [UIImage imageNamed:@"HistoryRepeatPaymentActivityMiniIcon.png"];
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

    if (![op availibleNow])
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

/*- (UIViewController *)activityViewController
{
    //Возвращаем конторллер отображения для действия
    svcTopCurrency *curr = [[svcTopCurrency alloc] init];
    curr.Label = self.operation.out_curr;
    curr.Name = self.operation.currName;
    curr.Parameters = self.operation.op_Parameters;
    curr.zeroComission = self.operation.zeroComission;
    curr.OutPossibleValues = self.operation.OutPossibleValues;
    PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:curr andSumma:self.operation.op_Sum];
    pp.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:pp];
    return nc;
}*/

#pragma mark PayViewControllerDelegate

- (void)finishPay:(UIViewController *)controller
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
