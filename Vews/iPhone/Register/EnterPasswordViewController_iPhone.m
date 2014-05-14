//
//  EnterPasswordViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 28.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "EnterPasswordViewController_iPhone.h"
#import "VerifyPasswordViewController_iPhone.h"
#import "AppDelegate.h"
#import "UITextFieldWithDelete.h"

@interface EnterPasswordViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar1;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar2;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar3;
@property (nonatomic, retain) IBOutlet UITextFieldWithDelete *tfChar4;

- (IBAction)btnContinue_Click:(id)sender;

@end

@implementation EnterPasswordViewController_iPhone

@synthesize tfChar1 = _tfChar1;
@synthesize tfChar2 = _tfChar2;
@synthesize tfChar3 = _tfChar3;
@synthesize tfChar4 = _tfChar4;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Register_EnterPassword_Title", @"Register_EnterPassword_Title");
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
    if ([self.tfChar1.text length] == 0)
    {
        self.tfChar1.userInteractionEnabled = YES;
        self.tfChar2.userInteractionEnabled = NO;
        self.tfChar3.userInteractionEnabled = NO;
        self.tfChar4.userInteractionEnabled = NO;
    
        [self.tfChar1 becomeFirstResponder];
    }
    else
    {
        self.tfChar1.userInteractionEnabled = NO;
        self.tfChar2.userInteractionEnabled = NO;
        self.tfChar3.userInteractionEnabled = NO;
        self.tfChar4.userInteractionEnabled = YES;
        
        [self.tfChar4 becomeFirstResponder];
    }
}

- (IBAction)btnContinue_Click:(id)sender
{
    [self.tfChar1 resignFirstResponder];
    [self.tfChar2 resignFirstResponder];
    [self.tfChar3 resignFirstResponder];
    [self.tfChar4 resignFirstResponder];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.userProfile.password = [NSString stringWithFormat:@"%@%@%@%@", self.tfChar1.text, self.tfChar2.text, self.tfChar3.text, self.tfChar4.text];
    [self.navigationController pushViewController:[[VerifyPasswordViewController_iPhone alloc] initWithNibName:@"VerifyPasswordViewController_iPhone" bundle:nil] animated:YES];
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
