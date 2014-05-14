//
//  CheckPasswordViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 08.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CheckPasswordViewController_iPhone.h"
#import "UITextFieldWithDelete.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"

@interface CheckPasswordViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar1;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar2;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar3;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar4;

@end

@implementation CheckPasswordViewController_iPhone

@synthesize tfChar1 = _tfChar1;
@synthesize tfChar2 = _tfChar2;
@synthesize tfChar3 = _tfChar3;
@synthesize tfChar4 = _tfChar4;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDelegate:(id<CheckPasswordDelegate>)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = delegate;
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
    [self prepareView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self prepareView];
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

- (void)check
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc CheckPassword:self action:@selector(checkPasswordHandler:) UNIQUE:[app.userProfile uid] Password:[NSString stringWithFormat:@"%@%@%@%@", self.tfChar1.text, self.tfChar2.text, self.tfChar3.text, self.tfChar4.text]];
}

- (void)checkPasswordHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[NSError class]])
    {
        //Возможно надо показывать более конкретное сообщение в этом случае
        NSError *err = (NSError *)response;
        if ([err.domain isEqualToString:@"SudzC"]) return;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnableCheckPassword_Title", @"UnableCheckPassword_Title") message:err.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
        [alert show];
        [self prepareView];
        return;
    }
    if ([response isKindOfClass:[NSError class]])
        return;
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            [app playProfileSound];
            [self.delegate passwordChecked:self withResult:YES];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WrongPassword_Title", @"WrongPassword_Title") message:NSLocalizedString(@"WrongPassword_Message", @"WrongPassword_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
            [alert show];
            [self prepareView];
        }
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnableCheckPassword_Title", @"UnableCheckPassword_Title") message:NSLocalizedString(@"UnableCheckPassword_Message", @"UnableCheckPassword_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
    [self prepareView];
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
                [app showWait:NSLocalizedString(@"CheckPassword_WaitMessage", @"CheckPassword_WaitMessage")];
                [self performSelector:@selector(check) withObject:nil afterDelay:.1];
                return NO;
            }
        }
        if (textField == self.tfChar4)
        {
            [self.tfChar4 resignFirstResponder];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app showWait:NSLocalizedString(@"CheckPassword_WaitMessage", @"CheckPassword_WaitMessage")];
            [self performSelector:@selector(check) withObject:nil afterDelay:.1];
            return NO;
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
