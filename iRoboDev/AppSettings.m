//
//  AppSettings.m
//  iRobo
//
//  Created by Ivan Alekseev on 24.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "AppSettings.h"

@implementation AppSettings

@synthesize blurWhenBackground = _blurWhenBackground;
@synthesize passwordTimeout = _passwordTimeout;
@synthesize useSound = _useSound;
@synthesize storeCVC = _storeCVC;

- (void)loadSettings
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud synchronize])
    {
        self.blurWhenBackground = [ud boolForKey:@"blur_preference"];
        self.passwordTimeout = [ud integerForKey:@"timeout_preference"];
        self.useSound = [ud boolForKey:@"sound_preference"];
        if (self.passwordTimeout == 0)
            self.passwordTimeout = 1;
        self.storeCVC = [ud boolForKey:@"store_cvc"];
    }
    else
    {
        self.blurWhenBackground = YES;
        self.passwordTimeout = 1;
        self.useSound = YES;
        self.storeCVC = YES;
    }
}

- (void)setStoreCVCToNO
{
    self.storeCVC = NO;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud synchronize]) {
        [ud setValue:self.storeCVC ? @"YES" : @"NO" forKey:@"store_cvc"];
    }
}

@end
