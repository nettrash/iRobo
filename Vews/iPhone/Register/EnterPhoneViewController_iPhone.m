//
//  EnterPhoneViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 27.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "EnterPhoneViewController_iPhone.h"
#import "AppDelegate.h"
#import "EnterEMailViewController_iPhone.h"

@interface EnterPhoneViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextField *tfPhoneCountry;
@property (nonatomic, retain) IBOutlet UITextField *tfPhoneCode;
@property (nonatomic, retain) IBOutlet UITextField *tfPhoneNumber;

- (IBAction)btnContinue_Click:(id)sender;

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
        [self.navigationItem setHidesBackButton:YES animated:YES];
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

- (IBAction)btnContinue_Click:(id)sender
{
    [self.tfPhoneCode resignFirstResponder];
    [self.tfPhoneNumber resignFirstResponder];
    
    if ([self.tfPhoneCode.text length] == 3 && [self.tfPhoneNumber.text length] == 7)
    {
        NSString *phone = [NSString stringWithFormat:@"%@%@%@", self.tfPhoneCountry.text, self.tfPhoneCode.text, self.tfPhoneNumber.text];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([app.userProfile setProfilePhone:phone])
        {
            [app.userProfile saveChanges];
            [self.navigationController pushViewController:[[EnterEMailViewController_iPhone alloc] initWithNibName:@"EnterEMailViewController_iPhone" bundle:nil] animated:YES];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPhoneError_Title", @"EnterPhoneError_Title") message:NSLocalizedString(@"EnterPhoneError_Message", @"EnterPhoneError_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EnterPhoneError_Title", @"EnterPhoneError_Title") message:NSLocalizedString(@"EnterPhoneError_Message", @"EnterPhoneError_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
        [alert show];
    }
}

- (void)prepareView
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *phone = [NSString stringWithString:app.userProfile.phone];
    if (phone && [phone length] > 10)
    {
        self.tfPhoneCode.text = [phone substringWithRange:NSMakeRange([phone length] - 10, 3)];
        self.tfPhoneNumber.text = [phone substringWithRange:NSMakeRange([phone length] - 7, 7)];
    }
    else
    {
        [self.tfPhoneCode becomeFirstResponder];
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
    //Если строка содержит что-то кроме цифр, то нет
    //тут код проверки RegEx
    if ([textField.text length] > [str length])
    {
        //Удаление
        if (textField == self.tfPhoneNumber && [str length] == 0)
        {
            textField.text = str;
            [self.tfPhoneCode becomeFirstResponder];
            return NO;
        }
    }
    else
    {
        //Добавление
        if (textField == self.tfPhoneCode && [str length] > 2)
        {
            if ([str length] != 3) return NO;
            textField.text = str;
            [self.tfPhoneNumber becomeFirstResponder];
            return NO;
        }
        if (textField == self.tfPhoneNumber && [str length] > 6)
        {
            if ([str length] == 7)
                textField.text = str;
            [self btnContinue_Click:nil];
            return NO;
        }
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
