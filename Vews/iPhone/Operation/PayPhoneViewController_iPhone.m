//
//  PayPhoneViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 28.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "PayPhoneViewController_iPhone.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "NSNumber+Currency.h"
#import "EnterCVCViewController_iPhone.h"
#import "OperationStateViewController_iPhone.h"
#import "ComissionViewController_iPhone.h"
#import "UIViewController+KeyboardExtensions.h"

@interface PayPhoneViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextField *tfPhoneCountry;
@property (nonatomic, retain) IBOutlet UITextField *tfPhoneCode;
@property (nonatomic, retain) IBOutlet UITextField *tfPhoneNumber;
@property (nonatomic, retain) IBOutlet UIPickerView *pvSumma;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) EnterCVCViewController_iPhone *cvcView;
@property (nonatomic, retain) IBOutlet UILabel *lblPeople;

- (IBAction)btnContinue_Click:(id)sender;
- (IBAction)btnChooseFromAB_Click:(id)sender;

@end

@implementation PayPhoneViewController_iPhone

@synthesize delegate = _delegate;
@synthesize tfPhoneCountry = _tfPhoneCountry;
@synthesize tfPhoneCode = _tfPhoneCode;
@synthesize tfPhoneNumber = _tfPhoneNumber;
@synthesize pvSumma = _pvSumma;
@synthesize doneButton = _doneButton;
@synthesize cvcView = _cvcView;
@synthesize lblPeople = _lblPeople;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"PayPhone_Title", @"PayPhone_Title");
        _summa = [NSDecimalNumber decimalNumberWithString:@"500"];
        _availibleSumms = [NSArray arrayWithObjects:
                           [NSDecimalNumber decimalNumberWithString:@"100"],
                           [NSDecimalNumber decimalNumberWithString:@"200"],
                           [NSDecimalNumber decimalNumberWithString:@"500"],
                           [NSDecimalNumber decimalNumberWithString:@"1000"],
                           [NSDecimalNumber decimalNumberWithString:@"1500"],
                           [NSDecimalNumber decimalNumberWithString:@"2000"],
                           [NSDecimalNumber decimalNumberWithString:@"5000"],
                           nil];
        _keyboardIsShowing = NO;
        _needToShowDoneButton = NO;
        _opKey = nil;
        _comissionViewController = nil;
    }
    return self;
}

- (void)refreshPeople:(NSString *)phone
{
    self.lblPeople.text = @"";
    @try {
        CFErrorRef *error = NULL;
        
        ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, error);
        
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressbook);
        CFIndex numPeople = ABAddressBookGetPersonCount(addressbook);
        for (int i=0; i < numPeople; i++) {
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            CFStringRef name = ABRecordCopyCompositeName(person);
            
            CFTypeRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSArray *phones = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);

            NSString *expression = @"[A-z ()\\-]";
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
            
            for (NSString *ph in phones) {
                NSString *p = [regex stringByReplacingMatchesInString:ph options:0 range:NSMakeRange(0, [ph length]) withTemplate:@""];
                p = [p substringFromIndex:[p length] - 10];
                if ([p isEqualToString:[phone substringFromIndex:[phone length] - 10]]) {
                    self.lblPeople.text = (__bridge NSString*)name;
                    return;
                }
            }
        }
    }
    @catch (NSException *exception) {
        self.lblPeople.text = @"";
    }
    @finally {
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton.frame = CGRectMake(0, 163, 106, 53);
    self.doneButton.adjustsImageWhenHighlighted = NO;
    
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateApplication];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateDisabled];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateHighlighted];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateReserved];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateSelected];

    self.cvcView = [[EnterCVCViewController_iPhone alloc] initWithNibName:@"EnterCVCViewController_iPhone" bundle:nil];
    self.cvcView.delegate = self;
    [self.doneButton addTarget:self.cvcView action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.lblPeople.text = @"";
    [self prepareView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardDidShow:)
     name:UIKeyboardDidShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareView
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *phone = [NSString stringWithString:app.userProfile.phone];
    if (phone && [phone length] > 10)
    {
        self.tfPhoneCode.text = [phone substringWithRange:NSMakeRange([phone length] - 10, 3)];
        self.tfPhoneNumber.text = [phone substringWithRange:NSMakeRange([phone length] - 7, 7)];
        [self refreshPeople:phone];
    }
    else
    {
        [self.tfPhoneCode becomeFirstResponder];
    }
    [self.pvSumma selectRow:2 inComponent:0 animated:NO];
}

- (IBAction)btnContinue_Click:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"CheckPhone_WaitMessage", @"CheckPhone_WaitMessage")];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetCurrencyByPhone:self action:@selector(getCurrencyByPhoneHandler:) UNIQUE:[app.userProfile uid] Phone:[NSString stringWithFormat:@"%@%@%@", self.tfPhoneCountry.text, self.tfPhoneCode.text, self.tfPhoneNumber.text]];
}

- (void)getCurrencyByPhoneHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result && resp.catalog && resp.catalog != nil && [resp.catalog count] == 1 && resp.parameters && resp.parameters != nil && [resp.parameters count] == 1)
        {
            _currency = (svcCurrency *)[resp.catalog objectAtIndex:0];
            _parameter = (svcParameter *)[resp.parameters objectAtIndex:0];
            [self performSelector:@selector(selectCard:) withObject:nil afterDelay:.1];
            return;
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GetCurrencyByPhoneError_Title", @"GetCurrencyByPhoneError_Title") message:NSLocalizedString(@"GetCurrencyByPhoneError_Message", @"GetCurrencyByPhoneError_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
            [alert show];
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkRequestError_Title", @"NetworkRequestError_Title") message:NSLocalizedString(@"NetworkRequestError_Message", @"NetworkRequestError_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
}

- (void)selectCard:(id)sender
{
    CardsViewController_iPhone *cv = [[CardsViewController_iPhone alloc] initWithNibName:@"CardsViewController_iPhone" bundle:nil showUnauthorizedCards:NO withFormType:CardsViewFormTypeSelectView];
    cv.delegate = self;
    [self.navigationController pushViewController:cv animated:YES];
}

- (IBAction)btnChooseFromAB_Click:(id)sender
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    peoplePicker.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], nil];
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

- (void)enterCVC
{
    _needToShowDoneButton = YES;
    [self.cvcView performSelector:@selector(addToViewController:) withObject:self.navigationController.topViewController afterDelay:.1];
}

- (void)showComission
{
    [self hideKeyboard];
    _comissionViewController = [[ComissionViewController_iPhone alloc] initWithNibName:@"ComissionViewController_iPhone" bundle:nil currency:[_currency Label] OutSumma:_summa cardId:[_card card_Id]];
    _comissionViewController.delegate = self;
    [_comissionViewController performSelector:@selector(addToViewController:) withObject:self.navigationController.topViewController afterDelay:.1];
}

- (void)startOperation:(NSString *)cvc
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"StartOperation_WaitMessage", @"StartOperation_WaitMessage")];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;

    NSString *prms = [NSString stringWithFormat:@"%@:%@", [_parameter Name], [NSString stringWithFormat:@"%@%@", self.tfPhoneCode.text, self.tfPhoneNumber.text]];
    [svc StartOperation:self action:@selector(startOperationHandler:) UNIQUE:[app.userProfile uid] cardId:[_card card_Id] summa:_summa currency:[_currency Label] parameters:prms CVC:cvc];
}

- (void)startOperationHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result && resp.OpKey && ![resp.OpKey isEqualToString:@""])
        {
            _opKey = resp.OpKey;
            if ([_card card_IsOCEAN])
            {
                //Завершаем с сообщением что распоряжение принято
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PaymentByOCEANStart_Title", @"PaymentByOCEANStart_Title") message:NSLocalizedString(@"PaymentByOCEANStart_Message", @"PaymentByOCEANStart_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
                [alert show];
                [self.delegate finishPay:self];
            }
            else
            {
                OperationStateViewController_iPhone *ov = [[OperationStateViewController_iPhone alloc] initWithNibName:@"OperationStateViewController_iPhone" bundle:nil OpKey:_opKey];
                ov.delegate = self;
                [self.navigationController pushViewController:ov animated:YES];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PaymentStart_Title", @"PaymentStart_Title") message:resp.errortext delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark NumberPadKeyboard

- (void)keyboardWillShow:(NSNotification *)note
{
	if (_keyboardIsShowing) return;
	_keyboardIsShowing = YES;
    if (_needToShowDoneButton)
        [self addDoneButtonToNumberPadKeyboard];
    else
        [self removeDoneButtonFromNumberPadKeyboard];
}

- (void)keyboardDidShow:(NSNotification *)note
{
    if (_needToShowDoneButton)
        [self addDoneButtonToNumberPadKeyboard];
    else
        [self removeDoneButtonFromNumberPadKeyboard];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    if (_keyboardIsShowing) {
        [self removeDoneButtonFromNumberPadKeyboard];
        _keyboardIsShowing = NO;
	}
}

- (void)addDoneButtonToNumberPadKeyboard
{
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for (int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                [keyboard addSubview:self.doneButton];
        } else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                [keyboard addSubview:self.doneButton];
        }
    }
}

- (void)removeDoneButtonFromNumberPadKeyboard
{
	if (!_keyboardIsShowing) return;
	
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for (int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                break;
        } else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                break;
        }
    }
	for ( int i = 0; i < [keyboard.subviews count]; i++) {
		if ([[keyboard.subviews objectAtIndex:i] isKindOfClass:[UIButton class]]) {
			UIButton *btnDone = (UIButton *)[keyboard.subviews objectAtIndex:i];
			if (btnDone == self.doneButton) {
				[self.doneButton removeFromSuperview];
				return;
			}
		}
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
            [self.tfPhoneNumber resignFirstResponder];
            [self refreshPeople:[NSString stringWithFormat:@"%@%@%@", self.tfPhoneCountry.text, self.tfPhoneCode.text, self.tfPhoneNumber.text]];
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

#pragma mark ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
            self.tfPhoneCode.text = [phone substringWithRange:NSMakeRange([phone length] - 10, 3)];
            self.tfPhoneNumber.text = [phone substringWithRange:NSMakeRange([phone length] - 7, 7)];
            [self refreshPeople:phone];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ABPhoneSelect_NotRussia_Title", @"ABPhoneSelect_NotRussia_Title") message:NSLocalizedString(@"ABPhoneSelect_NotRussia_Message", @"ABPhoneSelect_NotRussia_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
            [alert show];
        }
    }
    return NO;
}

#pragma mark CardsViewControllerDelegate

- (void)cardSelected:(svcCard *)card controller:(UIViewController *)controller
{
    _card = card;
    [self enterCVC];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_availibleSumms count];
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0: {
            NSString *s = [(NSDecimalNumber *)[_availibleSumms objectAtIndex:row] numberWithCurrencyShort];
            NSString *fs = @"";
            switch (row) {
                case 0:
                    fs = NSLocalizedString(@"PayPhoneSumm0", @"");
                    break;
                case 1:
                    fs = NSLocalizedString(@"PayPhoneSumm1", @"");
                    break;
                case 2:
                    fs = NSLocalizedString(@"PayPhoneSumm2", @"");
                    break;
                case 3:
                    fs = NSLocalizedString(@"PayPhoneSumm3", @"");
                    break;
                case 4:
                    fs = NSLocalizedString(@"PayPhoneSumm4", @"");
                    break;
                case 5:
                    fs = NSLocalizedString(@"PayPhoneSumm5", @"");
                    break;
                case 6:
                    fs = NSLocalizedString(@"PayPhoneSumm6", @"");
                    break;
                case 7:
                    fs = NSLocalizedString(@"PayPhoneSumm7", @"");
                    break;
                case 8:
                    fs = NSLocalizedString(@"PayPhoneSumm8", @"");
                    break;
                case 9:
                    fs = NSLocalizedString(@"PayPhoneSumm9", @"");
                    break;
                default:
                    fs = @"%@";
                    break;
            }
            return  [NSString stringWithFormat:fs, s];
        }
        default:
            return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
        _summa = (NSDecimalNumber *)[_availibleSumms objectAtIndex:row];
}

#pragma mark EnterCVCDelegate

-(void)finishEnterCVC:(UIViewController *)controller cvcEntered:(BOOL)cvcEntered cvcValue:(NSString*)cvcValue
{
    _needToShowDoneButton = NO;
    if (cvcEntered)
    {
        [(EnterCVCViewController_iPhone *)controller removeFromViewController];
        _cvc = cvcValue;
        if (_card.card_IsOCEAN)
            [self performSelector:@selector(startOperation:) withObject:cvcValue afterDelay:.1];
        else
        {
            [self showComission];
        }
    }
    else
    {
        [self.delegate finishPay:self];
    }
}

#pragma mark OperationStateDelegate

- (void)operationIsComplete:(UIViewController *)controller success:(BOOL)success
{
    if (success)
    {
        //Надо показать успешность оплаты
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PaymentEnd_Title", @"PaymentEnd_Title") message:NSLocalizedString(@"PaymentEnd_Success_Message", @"PaymentEnd_Success_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        //Надо показать неуспешность оплаты
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PaymentEnd_Title", @"PaymentEnd_Title") message:NSLocalizedString(@"PaymentEnd_Fail_Message", @"PaymentEnd_Fail_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
        [alert show];
    }
    [self.delegate finishPay:self];
}

#pragma mark ComissionAcceptDelegate

- (void)acceptingComissionFinished:(UIViewController *)controller withResult:(BOOL)result
{
    if (result)
    {
        [_comissionViewController removeFromViewController];
        [self performSelector:@selector(startOperation:) withObject:_cvc afterDelay:.1];
    }
    else
    {
        [self.delegate finishPay:self];
    }
}

@end
