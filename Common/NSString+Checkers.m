//
//  NSString+Checkers.m
//  iRobo
//
//  Created by Ivan Alekseev on 12.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "NSString+Checkers.h"
#import "NSString+RegEx.h"

@implementation NSString (Checkers)

- (BOOL)isRobodQRCommand
{
    return ([self hasPrefix:@"https://misc.roboxchange.com/External/iPhone/linktorobokassa.ashx"] ||
            [self hasPrefix:@"robokassa://"] ||
            [self hasPrefix:@"robod://"] ||
            [self hasPrefix:@"card2card://"]);
}

- (BOOL)isVCARD
{
    return ([self hasPrefix:@"BEGIN:VCARD"] && [self hasSuffix:@"END:VCARD"]);
}

- (BOOL)isURL
{
    NSDataDetector *detector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [detector matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            return YES;
        }
    }
    return NO;
}

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

- (BOOL)isPossibleMoscowGKU
{
    return self && self != nil && [self length] == 28 && [self checkFormat:@"^\\d{28}$"];
}

- (BOOL)isPossibleMGTS
{
    return self && self != nil && [self length] == 21 && [self checkFormat:@"^\\d{21}$"];
}

- (BOOL)isPossibleMosenergosbut
{
    return self && self != nil && [self length] == 25 && [self checkFormat:@"^\\d{25}$"];
}

- (BOOL)isPossibleGIBDD
{
    return self && self != nil && [self length] == 20 && [self checkFormat:@"^\\d{20}$"];
}

- (BOOL)isST00011
{
    return [self hasPrefix:@"ST00011|"];
}

@end
