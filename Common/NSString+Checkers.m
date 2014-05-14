//
//  NSString+Checkers.m
//  iRobo
//
//  Created by Ivan Alekseev on 12.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "NSString+Checkers.h"

@implementation NSString (Checkers)

- (BOOL)isHTML
{
    return
        (
         ([self rangeOfString:@"<a" options:NSCaseInsensitiveSearch].location != NSNotFound) ||
         ([self rangeOfString:@"<b" options:NSCaseInsensitiveSearch].location != NSNotFound) ||
         ([self rangeOfString:@"<h" options:NSCaseInsensitiveSearch].location != NSNotFound) ||
         ([self rangeOfString:@"<i" options:NSCaseInsensitiveSearch].location != NSNotFound)
        ) &&
        (
         ([self rangeOfString:@"</" options:NSCaseInsensitiveSearch].location != NSNotFound) ||
         ([self rangeOfString:@"/>" options:NSCaseInsensitiveSearch].location != NSNotFound)
        );
}

- (NSString *)HTMLWithSystemFont
{
    return [NSString stringWithFormat:@"<font face=\"Gotham, Helvetica Neue, Helvetica, Arial, sans-serif\" size=\"+4\">%@</font>", self];
}

@end
