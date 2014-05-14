//
//  VerifyPasswordViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 28.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "VerifyPasswordViewController_iPhone.h"
#import "AcceptOfertaViewController_iPhone.h"
#import "AppDelegate.h"
#import "UITextFieldWithDelete.h"

@interface VerifyPasswordViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar1;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar2;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar3;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar4;

- (IBAction)btnContinue_Click:(id)sender;

@end

@implementation VerifyPasswordViewController_iPhone

@synthesize tfChar1 = _tfChar1;
@synthesize tfChar2 = _tfChar2;
@synthesize tfChar3 = _tfChar3;
@synthesize tfChar4 = _tfChar4;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Register_VerifyPassword_Title", @"Register_VerifyPassword_Title");
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

- (IBAction)btnContinue_Click:(id)sender
{
    [self.tfChar1 resignFirstResponder];
    [self.tfChar2 resignFirstResponder];
    [self.tfChar3 resignFirstResponder];
    [self.tfChar4 resignFirstResponder];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *password = [NSString stringWithFormat:@"%@%@%@%@", self.tfChar1.text, self.tfChar2.text, self.tfChar3.text, self.tfChar4.text];
    
    if ([password isEqualToString:app.userProfile.password])
    {
        app.userProfile.hasPassword = YES;
        [app.userProfile saveChanges];
        [self.navigationController pushViewController:[[AcceptOfertaViewController_iPhone alloc] initWithNibName:@"AcceptOfertaViewController_iPhone" bundle:nil] animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VerifyPasswordError_Title", @"VerifyPasswordError_Title") message:NSLocalizedString(@"VerifyPasswordError_Message", @"VerifyPasswordError_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
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
            [self.tfChar1 resignFirstResponder];
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
                [self btnContinue_Click:nil];
            }
        }
        if (textField == self.tfChar4)
        {
            [self.tfChar4 resignFirstResponder];
            [self btnContinue_Click:nil];
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
