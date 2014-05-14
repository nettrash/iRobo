//
//  ApprovePhoneViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 08.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "ApprovePhoneViewController_iPhone.h"
#import "UITextFieldWithDelete.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "ApproveEMailViewController_iPhone.h"

@interface ApprovePhoneViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar1;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar2;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar3;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar4;
@property (nonatomic, retain) IBOutlet UILabel *lblPhone;

@end

@implementation ApprovePhoneViewController_iPhone

@synthesize tfChar1 = _tfChar1;
@synthesize tfChar2 = _tfChar2;
@synthesize tfChar3 = _tfChar3;
@synthesize tfChar4 = _tfChar4;
@synthesize lblPhone = _lblPhone;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _initSMSSended = NO;
        self.navigationItem.title = NSLocalizedString(@"ApprovePhone_Titile", @"ApprovePhone_Titile");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.lblPhone.text = app.userProfile.phone;
    
    [self prepareView];
    if (!_initSMSSended)
        [self performSelector:@selector(sendSMS) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareView
{
    self.tfChar1.text = @"";
    self.tfChar2.text = @"";
    self.tfChar3.text = @"";
    self.tfChar4.text = @"";
    
    self.tfChar1.userInteractionEnabled = YES;
    self.tfChar2.userInteractionEnabled = NO;
    self.tfChar3.userInteractionEnabled = NO;
    self.tfChar4.userInteractionEnabled = NO;
    
    [self.tfChar1 becomeFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self prepareView];
}

- (void)sendSMS
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc CheckPhone:self action:@selector(checkPhoneHandler:) UNIQUE:[app.userProfile uid]];
}

- (void)checkPhoneHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            _initSMSSended = YES;
            [self prepareView];
            return;
        }
    }
    [self showCheckError];
}

- (void)showCheckError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PhoneCheckError_Title", @"PhoneCheckError_Title") message:NSLocalizedString(@"PhoneCheckError_Message", @"PhoneCheckError_Message") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_AnotherOne", @"Button_AnotherOne") otherButtonTitles:nil];
    [alert show];
}

- (void)showApproveError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PhoneApproveError_Title", @"PhoneApproveError_Title") message:NSLocalizedString(@"PhoneApproveError_Message", @"PhoneApproveError_Message") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_AnotherOne", @"Button_AnotherOne") otherButtonTitles:nil];
    [alert show];
    [self.tfChar4 becomeFirstResponder];
}

- (void)check
{
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *code = [NSString stringWithFormat:@"%@%@%@%@", self.tfChar1.text, self.tfChar2.text, self.tfChar3.text, self.tfChar4.text];
    [svc ApprovePhone:self action:@selector(approvePhoneHandler:) UNIQUE:[app.userProfile uid] Code:code];
}

- (void)approvePhoneHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            app.userProfile.phoneApproved = YES;
            [app.userProfile storeToCloud];
            [app.userProfile saveChanges];
            ApproveEMailViewController_iPhone *vc = [[ApproveEMailViewController_iPhone alloc] initWithNibName:@"ApproveEMailViewController_iPhone" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    }
    [self showApproveError];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self sendSMS];
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
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField.text length] > [str length] || ([textField.text length] == 0 && [str length] == 0))
    {
        //Удаление
        if (textField == self.tfChar4)
        {
            if ([textField.text length] == 0)
            {
                self.tfChar3.text = @"";
            }
            textField.text = @"";
            self.tfChar4.userInteractionEnabled = NO;
            self.tfChar3.userInteractionEnabled = YES;
            [self.tfChar3 becomeFirstResponder];
        }
        if (textField == self.tfChar3)
        {
            if ([textField.text length] == 0)
            {
                self.tfChar2.text = @"";
            }
            textField.text = @"";
            self.tfChar3.userInteractionEnabled = NO;
            self.tfChar2.userInteractionEnabled = YES;
            [self.tfChar2 becomeFirstResponder];
        }
        if (textField == self.tfChar2)
        {
            if ([textField.text length] == 0)
            {
                self.tfChar1.text = @"";
            }
            textField.text = @"";
            self.tfChar2.userInteractionEnabled = NO;
            self.tfChar1.userInteractionEnabled = YES;
            [self.tfChar1 becomeFirstResponder];
        }
        if (textField == self.tfChar1)
        {
            textField.text = @"";
            //[self.tfChar1 resignFirstResponder];
        }
        return NO;
    }
    else
    {
        if ([str length] > 2) return NO;
        //Добавление
        textField.text = [str substringWithRange:NSMakeRange(0, 1)];
        if (textField == self.tfChar1)
        {
            if ([str length] == 1)
            {
                self.tfChar1.userInteractionEnabled = NO;
                self.tfChar2.userInteractionEnabled = YES;
                [self.tfChar2 becomeFirstResponder];
            }
            else
            {
                self.tfChar2.text = [str substringWithRange:NSMakeRange(1, 1)];
                self.tfChar1.userInteractionEnabled = NO;
                self.tfChar3.userInteractionEnabled = YES;
                [self.tfChar3 becomeFirstResponder];
            }
        }
        if (textField == self.tfChar2)
        {
            if ([str length] == 1)
            {
                self.tfChar2.userInteractionEnabled = NO;
                self.tfChar3.userInteractionEnabled = YES;
                [self.tfChar3 becomeFirstResponder];
            }
            else
            {
                self.tfChar3.text = [str substringWithRange:NSMakeRange(1, 1)];
                self.tfChar2.userInteractionEnabled = NO;
                self.tfChar4.userInteractionEnabled = YES;
                [self.tfChar4 becomeFirstResponder];
            }
        }
        if (textField == self.tfChar3)
        {
            if ([str length] == 1)
            {
                self.tfChar3.userInteractionEnabled = NO;
                self.tfChar4.userInteractionEnabled = YES;
                [self.tfChar4 becomeFirstResponder];
            }
            else
            {
                self.tfChar4.text = [str substringWithRange:NSMakeRange(1, 1)];
                self.tfChar3.userInteractionEnabled = NO;
                self.tfChar4.userInteractionEnabled = YES;
                [self.tfChar3 resignFirstResponder];
                [self.tfChar4 resignFirstResponder];
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app showWait:NSLocalizedString(@"CheckPhone_WaitMessage", @"CheckPhone_WaitMessage")];
                [self performSelector:@selector(check) withObject:nil afterDelay:.1];
            }
        }
        if (textField == self.tfChar4)
        {
            [self.tfChar4 resignFirstResponder];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app showWait:NSLocalizedString(@"CheckPhone_WaitMessage", @"CheckPhone_WaitMessage")];
            [self performSelector:@selector(check) withObject:nil afterDelay:.1];
        }
        return NO;
    }
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
