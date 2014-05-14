//
//  NSString+RegEx.m
//  iRobo
//
//  Created by Ivan Alekseev on 23.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "NSString+RegEx.h"

@implementation NSString (RegEx)

- (BOOL)checkFormat:(NSString *)format
{
    if (format == nil || [format isEqualToString:@""])
        return YES;
    
    NSError *error;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:[format stringByReplacingOccurrencesOfString:@"\n" withString:@""] options:NSRegularExpressionCaseInsensitive error:&error];
    
    return [regExp numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, [self length])] > 0;
}

@end
