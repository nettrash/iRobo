//
//  NSURL+Parameters.m
//  iRobo
//
//  Created by Ivan Alekseev on 14.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "NSURL+Parameters.h"

@implementation NSURL (Parameters)

- (NSString *)parameterValue:(NSString *)parameterName
{
    NSArray *prms = [self.query componentsSeparatedByString:@"&"];
    if (!prms || prms == nil || [prms count] < 1) return nil;
    for (NSString *p in prms)
    {
        NSArray *pp = [p componentsSeparatedByString:@"="];
        if (!pp || pp == nil || [pp count] != 2) continue;
        if ([[(NSString *)[pp objectAtIndex:0] uppercaseString] isEqualToString:[parameterName uppercaseString]])
            return (NSString *)[pp objectAtIndex:1];
    }
    return nil;
}

@end
