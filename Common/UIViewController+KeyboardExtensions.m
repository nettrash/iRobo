//
//  UIViewController+KeyboardExtensions.m
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UIViewController+KeyboardExtensions.h"

@implementation UIViewController (KeyboardExtensions)

- (void)hideKeyboardCascade: (NSArray *)subviews
{
    if (!subviews || subviews == nil || [subviews count] < 1)
        return;
    for (id view in subviews) {
        if ([view isKindOfClass:[UITextField class]])
        {
            [view resignFirstResponder];
        }
        [self hideKeyboardCascade:((UIView *)view).subviews];
    }
}

- (void)hideKeyboard
{
    [self hideKeyboardCascade:self.view.subviews];
}

@end
