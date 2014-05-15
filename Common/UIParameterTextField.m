//
//  UIParameterTextField.m
//  iRobo
//
//  Created by Ivan Alekseev on 07.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UIParameterTextField.h"
#import "NSString+RegEx.h"

@implementation UIParameterTextField

- (id)initWithFrame:(CGRect)frame andParameter:(svcParameter *)prm
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parameter = prm;
        self.placeholder = [prm.Label uppercaseString];
        self.adjustsFontSizeToFitWidth = YES;
        self.textColor = [UIColor darkGrayColor];
        if ([self.parameter.Type isEqualToString:@"Options"])
        {
            _pvOptions = [[UIPickerView alloc] init];
            _pvOptions.dataSource = self;
            _pvOptions.delegate = self;
            self.inputView = _pvOptions;

            if (self.parameter.innerParameters && self.parameter.innerParameters != nil && [self.parameter.innerParameters count] > 0)
            {
                svcParameter *p = (svcParameter *)[self.parameter.innerParameters objectAtIndex:0];
                self.parameter.DefaultValue = p.Name;
                self.text = p.Label;
            }
        }
        else
        {
            if ([self.parameter.Label rangeOfString:@"елефон"].location != NSNotFound)
            {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
                UIImage *img = [UIImage imageNamed:@"Support.png"];

                [btn setImage:img forState:UIControlStateApplication];
                [btn setImage:img forState:UIControlStateDisabled];
                [btn setImage:img forState:UIControlStateHighlighted];
                [btn setImage:img forState:UIControlStateNormal];
                [btn setImage:img forState:UIControlStateReserved];
                [btn setImage:img forState:UIControlStateSelected];
                
                [btn addTarget:self action:@selector(chooseFromContact:) forControlEvents:UIControlEventTouchUpInside];
                
                self.rightViewMode = UITextFieldViewModeAlways;
                self.rightView = btn;
                self.keyboardType = UIKeyboardTypePhonePad;
            }
            else
            {
                self.keyboardType = UIKeyboardTypeDefault;
            }
            self.text = self.parameter.DefaultValue;
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)chooseFromContact:(id)sender
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    peoplePicker.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], nil];
    [[[[[UIApplication sharedApplication] delegate] window]rootViewController] presentViewController:peoplePicker animated:YES completion:nil];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.parameter.innerParameters && self.parameter.innerParameters != nil && [self.parameter.innerParameters count] > 0)
        return [self.parameter.innerParameters count];
    else
        return 0;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    svcParameter *p = (svcParameter *)[self.parameter.innerParameters objectAtIndex:row];
    return p.Label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    svcParameter *p = (svcParameter *)[self.parameter.innerParameters objectAtIndex:row];
    self.parameter.DefaultValue = p.Name;
    self.text = p.Label;
}

#pragma mark ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [[[[[UIApplication sharedApplication] delegate] window]rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property == kABPersonPhoneProperty)
    {
        CFTypeRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSArray *phones = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        CFRelease(phoneProperty);
        NSString *phone = (NSString *)[phones objectAtIndex:identifier];
        
        NSString *expression = @"[A-z ()\\-]";
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
        phone = [regex stringByReplacingMatchesInString:phone options:0 range:NSMakeRange(0, [phone length]) withTemplate:@""];
        
        if ([phone hasPrefix:@"+7"] || [phone hasPrefix:@"8"])
        {
            if (self.parameter.Format && self.parameter.Format != nil && ![self.parameter.Format isEqualToString:@""]) {
                NSString *str = [phone substringWithRange:NSMakeRange([phone length] - 10, 10)];
                if (![str checkFormat:self.parameter.Format]) {
                    str = [phone substringWithRange:NSMakeRange([phone length] - 11, 11)];
                    if (![str checkFormat:self.parameter.Format]) {
                        str = phone;
                    }
                }
                self.text = str;
            } else {
                self.text = phone;
            }
            [self.parameter setDefaultValue:self.text];
            if (self.delegate && self.delegate != nil && [self.delegate conformsToProtocol:@protocol(UITextFieldDelegate)] && [self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
                [self.delegate textFieldShouldEndEditing:self];
            }
            [[[[[UIApplication sharedApplication] delegate] window]rootViewController] dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ABPhoneSelect_NotRussia_Title", @"ABPhoneSelect_NotRussia_Title") message:NSLocalizedString(@"ABPhoneSelect_NotRussia_Message", @"ABPhoneSelect_NotRussia_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
            [alert show];
        }
    }
    return NO;
}

@end
