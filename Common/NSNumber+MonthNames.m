//
//  NSNumber+MonthNames.m
//  iRobo
//
//  Created by Ivan Alekseev on 15.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "NSNumber+MonthNames.h"

@implementation NSNumber (MonthExtensions)

- (NSString *)monthName
{
    switch ([self intValue])
    {
        case 1:
            return NSLocalizedString(@"jan", @"jan");
        case 2:
            return NSLocalizedString(@"feb", @"feb");
        case 3:
            return NSLocalizedString(@"mar", @"mar");
        case 4:
            return NSLocalizedString(@"apr", @"apr");
        case 5:
            return NSLocalizedString(@"may", @"may");
        case 6:
            return NSLocalizedString(@"jun", @"jun");
        case 7:
            return NSLocalizedString(@"jul", @"jul");
        case 8:
            return NSLocalizedString(@"aug", @"aug");
        case 9:
            return NSLocalizedString(@"sep", @"sep");
        case 10:
            return NSLocalizedString(@"okt", @"okt");
        case 11:
            return NSLocalizedString(@"nov", @"nov");
        case 12:
            return NSLocalizedString(@"dec", @"dec");
        default:
            return @"";
    }
}

@end
