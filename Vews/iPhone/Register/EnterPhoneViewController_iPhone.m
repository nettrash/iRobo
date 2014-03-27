//
//  EnterPhoneViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 27.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "EnterPhoneViewController_iPhone.h"

@interface EnterPhoneViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextField *tfPhoneCountry;
@property (nonatomic, retain) IBOutlet UITextField *tfPhoneCode;
@property (nonatomic, retain) IBOutlet UITextField *tfPhoneNumber;

@end

@implementation EnterPhoneViewController_iPhone

@synthesize tfPhoneCountry = _tfPhoneCountry;
@synthesize tfPhoneCode = _tfPhoneCode;
@synthesize tfPhoneNumber = _tfPhoneNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Register_EnterPhone_Title", @"Register_EnterPhone_Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tfPhoneCode becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //TODO: dsgdg
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

@end
