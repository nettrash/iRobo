//
//  UITextFieldWithDelete.m
//  iRobo
//
//  Created by Ivan Alekseev on 02.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UITextFieldWithDelete.h"

@implementation UITextFieldWithDelete

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)deleteBackward
{
    [super deleteBackward];
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
        [self.delegate textField:(UITextField *)self shouldChangeCharactersInRange:NSMakeRange(0,0) replacementString:@""];
    }
}

@end
