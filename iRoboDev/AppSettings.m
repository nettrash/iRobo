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

- (void)loadSettings
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud synchronize])
    {
        self.blurWhenBackground = [ud boolForKey:@"blur_preference"];
        self.passwordTimeout = [ud integerForKey:@"timeout_preference"];
    
        if (self.passwordTimeout == 0)
            self.passwordTimeout = 1;
    }
    else
    {
        self.blurWhenBackground = YES;
        self.passwordTimeout = 1;
    }
}

@end
