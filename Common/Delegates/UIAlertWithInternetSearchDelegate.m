//
//  UIAlertWithInternetSearchDelegate.m
//  iRobo
//
//  Created by Ivan Alekseev on 06.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UIAlertWithInternetSearchDelegate.h"

@implementation UIAlertWithInternetSearchDelegate

@synthesize Q = _Q;
@synthesize preparedQ = _preparedQ;

+ (id)initWithQ:(NSString *)Q
{
    UIAlertWithInternetSearchDelegate *a = [UIAlertWithInternetSearchDelegate alloc];
    a.Q = Q;
    a.preparedQ = [Q stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return a;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1: {
            //Yandex
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://yandex.ru/touchsearch?text=%@&from=os", self.preparedQ]];
            [[UIApplication sharedApplication] openURL:url];
            break;
        }
        case 2: {
            //Google
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://google.com/search?ie=UTF-8&hl=ru&q=%@", self.preparedQ]];
            [[UIApplication sharedApplication] openURL:url];
            break;
        }
        case 3: {
            //Bing
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://bing.com/search?q=%@", self.preparedQ]];
            [[UIApplication sharedApplication] openURL:url];
            break;
        }
        default:
            break;
    }
}

@end
