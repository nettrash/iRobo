//
//  UIAlertWithOpenURLDelegate.m
//  iRobo
//
//  Created by Ivan Alekseev on 06.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UIAlertWithOpenURLDelegate.h"

@implementation UIAlertWithOpenURLDelegate

@synthesize url = _url;

+ (id)initWithText:(NSString *)str
{
    UIAlertWithOpenURLDelegate *a = [UIAlertWithOpenURLDelegate alloc];
    NSString *sUrl = str;
    if (![sUrl hasPrefix:@"http://"] && ![sUrl hasPrefix:@"https://"])
        sUrl = [NSString stringWithFormat:@"http://%@", sUrl];
    a.url = [NSURL URLWithString:sUrl];
    return a;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1: {
            //Open
            [[UIApplication sharedApplication] openURL:self.url];
            break;
        }
        default:
            break;
    }
}


@end
