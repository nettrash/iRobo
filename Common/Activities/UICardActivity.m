//
//  UICardActivity.m
//  iRobo
//
//  Created by Ivan Alekseev on 06.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UICardActivity.h"

@implementation UICardActivity

@synthesize performByButton = _performByButton;
@synthesize resultDelegate = _resultDelegate;

- (UICardActivity *)initWithResultDelegate:(id<ActivityResultDelegate>)delegate
{
    self.resultDelegate = delegate;
    return self;
}

- (UIImage *)activityMiniImage
{
    return [super activityImage];
}

- (UIButton *)activityButtonWithIndex:(int)buttonIndex
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(52 * buttonIndex, 6, 40, 40)];
    btn.hidden = NO;
    
    UIImage *aimg = [self activityMiniImage];
    UIImage *img = [UIImage imageNamed:@"CardCellActivityBorder.png"];
    
    [btn setImage:aimg forState:UIControlStateApplication];
    [btn setImage:aimg forState:UIControlStateDisabled];
    [btn setImage:aimg forState:UIControlStateHighlighted];
    [btn setImage:aimg forState:UIControlStateNormal];
    [btn setImage:aimg forState:UIControlStateReserved];
    [btn setImage:aimg forState:UIControlStateSelected];
    
    [btn setBackgroundImage:img forState:UIControlStateApplication];
    [btn setBackgroundImage:img forState:UIControlStateDisabled];
    [btn setBackgroundImage:img forState:UIControlStateHighlighted];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn setBackgroundImage:img forState:UIControlStateReserved];
    [btn setBackgroundImage:img forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(activityButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

- (IBAction)activityButtonClick:(id)sender
{
    self.performByButton = YES;
    UIViewController *avc = [self activityViewController];
    if (avc == nil)
    {
        [self performActivity];
    }
    else
    {
        avc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:avc animated:YES completion:nil];
    }
}

- (void)activityDidFinishByButton
{
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
