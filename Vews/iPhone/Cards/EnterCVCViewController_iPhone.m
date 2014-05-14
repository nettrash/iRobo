//
//  EnterCVCViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 18.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "EnterCVCViewController_iPhone.h"

@interface EnterCVCViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextField *tfCVC;

@end

@implementation EnterCVCViewController_iPhone

@synthesize tfCVC = _tfCVC;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tfCVC.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addToViewController:(UIViewController *)controller
{
    self.view.frame = CGRectMake(0, controller.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [controller.view addSubview:self.view];
    [controller.view bringSubviewToFront:self.view];

    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.view.frame = CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self.tfCVC becomeFirstResponder];
                     }];
}

- (void)removeFromViewController
{
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.view.frame = CGRectMake(0, self.view.superview.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                     }];
}

- (IBAction)doneButton:(id)sender
{
    [self.tfCVC resignFirstResponder];
    [self.delegate finishEnterCVC:self cvcEntered:YES cvcValue:self.tfCVC.text];
}

@end
