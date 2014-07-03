//
//  NSDate+Operation.m
//  iRobo
//
//  Created by Ivan Alekseev on 02.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "NSDate+Operation.h"

@implementation NSDate (Operation)

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (NSInteger)monthsBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSMonthCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference month];
}

- (NSInteger)yearsBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSYearCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSYearCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSYearCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference year];
}

- (NSString *)operationDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    NSDate *now = [NSDate date];
    NSInteger days = [self daysBetweenDate:self andDate:now];
    NSInteger months = [self monthsBetweenDate:self andDate:now];
    NSInteger years = [self yearsBetweenDate:self andDate:now];
    
    NSString *dStr = @"";
    if (years == 0 || years == INT_MAX) {
        if (months == 0 || months == INT_MAX) {
            //В этом месяце
            switch (days) {
                case 0:
                    //Сегодня
                    dStr = @"Сегодня";
                    break;
                case 1:
                    //Вчера
                    dStr = @"Вчера";
                    break;
                case 2:
                    //Позавчера
                    dStr = @"Позавчера";
                default:
                    //В этом месяце (N-го)
                    [formatter setDateFormat:@"d'-го числа'"];
                    dStr = [formatter stringFromDate:self];
                    break;
            }
        } else {
            [formatter setDateFormat:@"d'-го' MMMM"];
            dStr = [formatter stringFromDate:self];
        }
    } else {
        [formatter setDateFormat:@"d'-го' MMMM yyyy года"];
        dStr = [formatter stringFromDate:self];
    }
    return dStr;
}

@end
