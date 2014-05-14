//
//  EnterEMailViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 27.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "EnterEMailViewController_iPhone.h"
#import "EnterPasswordViewController_iPhone.h"
#import "AppDelegate.h"

@interface EnterEMailViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextField *tfEMail;

- (IBAction)btnContinue_Click:(id)sender;

@end

@implementation EnterEMailViewController_iPhone

@synthesize tfEMail = _tfEMail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Register_EnterEMail_Title", @"Register_EnterEMail_Title");
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
    [self prepareView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareView
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *email = [NSString stringWithString:app.userProfile.email];
    if (email && [email length] > 0)
    {
        self.tfEMail.text = email;
        if (![app.userProfile checkEMail:email])
            [self.tfEMail becomeFirstResponder];
    }
    else
    {
        [self.tfEMail becomeFirstResponder];
    }
}

- (IBAction)btnContinue_Click:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([app.userProfile setProfileEMail:self.tfEMail.text])
    {
        [app.userProfile saveChanges];
        [self.tfEMail resignFirstResponder];
        [self.navigationController pushViewController:[[EnterPasswordViewController_iPhone alloc] initWithNibName:@"EnterPasswordViewController_iPhone" bundle:nil] animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterEMailError_Title", @"EnterEMailError_Title") message:NSLocalizedString(@"EnterEMailError_Message", @"EnterEMailError_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
        [alert show];
    }
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
    [self btnContinue_Click:nil];
    return YES;
}

@end
