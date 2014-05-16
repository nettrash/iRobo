//
//  PayCheckViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 07.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "PayCheckViewController_iPhone.h"
#import "NSNumber+Currency.h"
#import "svcCurrency.h"
#import "UIParameterTextField.h"
#import "EnterCVCViewController_iPhone.h"
#import "UIViewController+KeyboardExtensions.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"
#import "svcParameter.h"
#import "NSString+RegEx.h"
#import "OperationStateViewController_iPhone.h"
#import "CardsViewController_iPhone.h"

#define BANKOCEAN2R @"BANKOCEAN2R"

@interface PayCheckViewController_iPhone ()

@property (nonatomic, retain) svcCheck *check;
@property (nonatomic, retain) IBOutlet UITableViewController *tblCheck;
@property (nonatomic, retain) UITextField *tfMethod;
@property (nonatomic, retain) EnterCVCViewController_iPhone *cvcView;
@property (nonatomic, retain) UIButton *doneButton;

@end

@implementation PayCheckViewController_iPhone

@synthesize delegate = _delegate;
@synthesize check = _check;
@synthesize tblCheck = _tblCheck;
@synthesize tfMethod = _tfMethod;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withCheck:(svcCheck *)check
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.check = check;
        _selectedCurrency = -1;
        _needToShowDoneButton = NO;
        _parameterRefreshing = NO;
        _parameters = [NSMutableDictionary dictionaryWithCapacity:0];
        [_parameters setObject:[NSMutableArray arrayWithCapacity:0] forKey:BANKOCEAN2R];
        _card = nil;
        _pvMethods = [[UIPickerView alloc] init];
        _pvMethods.dataSource = self;
        _pvMethods.delegate = self;
        self.navigationItem.title = NSLocalizedString(@"PayCheck_Title", @"PayCheck_Title");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PayButton_Title", @"PayButton_Title") style:UIBarButtonItemStyleDone target:self action:@selector(btnPay_Click:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tfMethod = [[UITextField alloc] initWithFrame:CGRectMake(110, 12, 180, 22)];
    self.tfMethod.inputView = _pvMethods;
    self.tfMethod.text = NSLocalizedString(@"CheckPay_PayMethod_Card", @"CheckPay_PayMethod_Card");
    self.tfMethod.delegate = self;
    self.tfMethod.font = [UIFont systemFontOfSize:12];
    self.tfMethod.textColor = [UIColor darkGrayColor];

    self.cvcView = [[EnterCVCViewController_iPhone alloc] initWithNibName:@"EnterCVCViewController_iPhone" bundle:nil];
    self.cvcView.delegate = self;
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton.frame = CGRectMake(0, 163, 106, 53);
    self.doneButton.adjustsImageWhenHighlighted = NO;
    
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateApplication];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateDisabled];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateHighlighted];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateReserved];
    [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateSelected];
    
    [self.doneButton addTarget:self.cvcView action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tblCheck.view removeFromSuperview];
    
    self.tblCheck.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20);
    if (_keyboardIsShowing) {
        CGRect frame = self.tblCheck.view.frame;
        frame.size.height -= [_keyboardHeight floatValue];
        self.tblCheck.view.frame = frame;
	}
    
    [self.view addSubview:self.tblCheck.view];

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
    
    if (![[self.check.State uppercaseString] isEqualToString:@"NEW"])
    {
        [self performSelector:@selector(gotoState:) withObject:self.check.OpKey afterDelay:1];
    }
}

- (void)keyboardWillShow : (NSNotification *) note
{
	if (_keyboardIsShowing) return;
    
    CGRect keyboardBounds;
	
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
	
    _keyboardHeight = [NSNumber numberWithFloat:keyboardBounds.size.height];
	
	_keyboardIsShowing = YES;
	
    if (_needToShowDoneButton)
        [self addDoneButtonToNumberPadKeyboard];
    else
        [self removeDoneButtonFromNumberPadKeyboard];
    
	CGRect frame = self.tblCheck.view.frame;
	frame.size.height -= [_keyboardHeight floatValue];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	
	self.tblCheck.view.frame = frame;
	
	[UIView commitAnimations];
}

- (void)keyboardDidShow : (NSNotification *) note
{
    if (_needToShowDoneButton)
        [self addDoneButtonToNumberPadKeyboard];
    else
        [self removeDoneButtonFromNumberPadKeyboard];
}

- (void)keyboardWillHide : (NSNotification *) note
{
    if (_keyboardIsShowing) {
        [self removeDoneButtonFromNumberPadKeyboard];
        _keyboardIsShowing = NO;
        CGRect frame = self.tblCheck.view.frame;
        frame.size.height += [_keyboardHeight floatValue];
		
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
		
        self.tblCheck.view.frame = frame;
		
        [UIView commitAnimations];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoState:(NSString *)opKey
{
    OperationStateViewController_iPhone *ov = [[OperationStateViewController_iPhone alloc] initWithNibName:@"OperationStateViewController_iPhone" bundle:nil OpKey:self.check.OpKey];
    ov.delegate = self;
    [self.navigationController pushViewController:ov animated:YES];
}

- (NSString *)getSavedParameterValue:(NSString *)parameter forCurrency:(NSString*)currency
{
    return @"";
}

- (void)setSavedParameterValue:(NSString *)parameter forCurrency:(NSString*)currency andValue:(NSString*)value
{
    
}

- (NSString *)selectedCurrencyLabel
{
    NSString *lbl = BANKOCEAN2R;
    if (_selectedCurrency > -1)
        lbl = [(svcCurrency *)[self.check.AdditionalCurrencies objectAtIndex:_selectedCurrency] Label];
    return lbl;
}

- (void)loadParameters
{
    NSString *lbl = [self selectedCurrencyLabel];
    _selectedCurrencyParameters = [_parameters objectForKey:lbl];
    self.tfMethod.enabled = YES;
    _parameterRefreshing = NO;
    if (_selectedCurrency > -1 && _selectedCurrencyParameters == nil)
    {
        self.tfMethod.enabled = NO;
        //Обновляем параметры с сервера
        _parameterRefreshing = YES;
        svcWSMobileBANK *svc = [svcWSMobileBANK service];
        svc.logging = YES;
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [svc GetIncParameters:self action:@selector(getParametersHandler:) UNIQUE:[app.userProfile uid] currency:lbl checkId:self.check.checkId];
    }
    [self.tblCheck.tableView reloadData];
    [self.tfMethod resignFirstResponder];
    [self validate];
}

- (void)getParametersHandler:(id)response
{
    _parameterRefreshing = NO;
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            [_parameters setObject:[NSArray arrayWithArray:resp.parameters] forKey:[self selectedCurrencyLabel]];
            [self loadParameters];
        }
    }
}

- (void)chooseCard:(id)sender
{
    CardsViewController_iPhone *cv = [[CardsViewController_iPhone alloc] initWithNibName:@"CardsViewController_iPhone" bundle:nil showUnauthorizedCards:NO withFormType:CardsViewFormTypeSelectView];
    cv.delegate = self;
    [self.navigationController pushViewController:cv animated:YES];
}

- (void)enterCVC
{
    _needToShowDoneButton = YES;
    [self.cvcView performSelector:@selector(addToViewController:) withObject:self.navigationController.topViewController afterDelay:.1];
}

- (void)validate
{
    BOOL bValid = YES;
    
    if (_parameterRefreshing)
        bValid = NO;
    else
    {
        if (_selectedCurrency > -1)
        {
            for (svcParameter *p in _selectedCurrencyParameters)
            {
                if (![p.DefaultValue checkFormat:p.Format])
                {
                    bValid = NO;
                    break;
                }
            }
        }
    }
    self.navigationItem.rightBarButtonItem.enabled = bValid;
}

- (void)btnPay_Click:(id)sender
{
    [self hideKeyboard];
    if (_selectedCurrency < 0)
    {
        [self chooseCard:sender];
    }
    else
    {
        [self payCheck];
    }
}

- (void)payCheck
{
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"StartCheckOperation_WaitMessage", @"StartCheckOperation_WaitMessage")];
    if (_selectedCurrency < 0)
    {
        [svc PayCheck:self action:@selector(payCheckHandler:) UNIQUE:[app.userProfile uid] checkId:self.check.checkId cardId:_card.card_Id CVC:_cvc];
    }
    else
    {
        NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
        
        for (svcParameter *p in _selectedCurrencyParameters) {
            [a addObject:[NSString stringWithFormat:@"%@:%@", p.Name, p.DefaultValue]];
        }
        
        [svc PayCheckWithCurrency:self action:@selector(payCheckHandler:) UNIQUE:[app.userProfile uid] checkId:self.check.checkId currency:[self selectedCurrencyLabel] parameters:[a componentsJoinedByString:@";"]];
    }
}

- (void)payCheckHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result && resp.OpKey && ![resp.OpKey isEqualToString:@""])
        {
            if ([_card card_IsOCEAN])
            {
                //Завершаем с сообщением что распоряжение принято
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PaymentByOCEANStart_Title", @"PaymentByOCEANStart_Title") message:NSLocalizedString(@"PaymentByOCEANStart_Message", @"PaymentByOCEANStart_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
                [alert show];
                [self.delegate finishPay:self];
            }
            else
            {
                OperationStateViewController_iPhone *ov = [[OperationStateViewController_iPhone alloc] initWithNibName:@"OperationStateViewController_iPhone" bundle:nil OpKey:resp.OpKey];
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

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_selectedCurrency == -1) {
        return 2;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
        case 1:
            return 1;
        case 2: {
            if (_selectedCurrency == -1) {
                return 0;
            }
            else {
                if (_parameterRefreshing) return 1;
                return [_selectedCurrencyParameters count];
            }
        }
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"PayCheckSection_CheckInfo", @"PayCheckSection_CheckInfo");
        case 1:
            return NSLocalizedString(@"PayCheckSecition_PaymentMethod", @"PayCheckSecition_PaymentMethod");
        case 2:
            return NSLocalizedString(@"PayCheckSecition_Parameters", @"PayCheckSecition_Parameters");
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"CheckCell";
 
    switch (indexPath.section) {
        case 0:
            identifier = @"CheckInfo";
            break;
        case 1:
            identifier = @"CheckPay";
            break;
        case 2:
            if (_parameterRefreshing) {
                identifier = @"CheckPayParameterRefreshing";
            }
            else {
                identifier = [NSString stringWithFormat:@"CheckPay_%i_%i", _selectedCurrency, indexPath.row];
            }
            break;
        default:
            break;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    BOOL dequeued = YES;
    
    if (indexPath.section == 2 && !_parameterRefreshing)
        cell = nil;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        dequeued = NO;
    }
    
    switch (indexPath.section) {
        case 0: {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.imageView.image = nil;
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"CheckInfo_Shop", @"CheckInfo_Shop");
                    cell.detailTextLabel.text = self.check.MerchantName;
                    break;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"CheckInfo_ShopOrder", @"CheckInfo_ShopOrder");
                    cell.detailTextLabel.text = self.check.MerchantOrder;
                    break;
                }
                case 2: {
                    cell.textLabel.text = NSLocalizedString(@"CheckInfo_ShopOrderDate", @"CheckInfo_ShopOrderDate");
                    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:self.check.RegDate
                                                                               dateStyle:NSDateFormatterShortStyle
                                                                               timeStyle:NSDateFormatterShortStyle];
                    break;
                }
                case 3: {
                    cell.textLabel.text = NSLocalizedString(@"CheckInfo_ShopOrderSumma", @"CheckInfo_ShopOrderSumma");
                    cell.detailTextLabel.text = [self.check.Summa numberWithCurrency];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1: {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.imageView.image = nil;
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.textLabel.text = NSLocalizedString(@"CheckPay_PaymentMethod", @"CheckPay_PaymentMethod");
            if (!dequeued) {
                [cell addSubview:self.tfMethod];
            }
            break;
        }
        case 2: {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.imageView.image = nil;
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (_parameterRefreshing)
            {
                if (!dequeued)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] init];
                    ai.hidesWhenStopped = YES;
                    [ai startAnimating];
                    cell.accessoryView = ai;
                }
                cell.textLabel.text = NSLocalizedString(@"CheckInfo_PaymentMethod_ParameterRefresh_Title", @"CheckInfo_PaymentMethod_ParameterRefresh_Title");
                cell.detailTextLabel.text = NSLocalizedString(@"CheckInfo_PaymentMethod_ParameterRefresh_Details", @"CheckInfo_PaymentMethod_ParameterRefresh_Details");
            }
            else
            {
                svcParameter *p = (svcParameter *)[_selectedCurrencyParameters objectAtIndex:indexPath.row];
                if (!dequeued)
                {
                    UIParameterTextField *tf = [[UIParameterTextField alloc] initWithFrame:CGRectMake(15, 12, 285, 22) andParameter:p];
                    tf.delegate = self;
                    [cell addSubview:tf];
                }
            }
            break;
        }
        default:
            return nil;
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.check.AdditionalCurrencies count] + 1;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0)
        return NSLocalizedString(@"CheckPay_PayMethod_Card", @"CheckPay_PayMethod_Card");
    else
    {
        svcCurrency *c = (svcCurrency *)[self.check.AdditionalCurrencies objectAtIndex:row-1];
        return c.Name;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedCurrency = row - 1;
    switch (row) {
        case 0:
            self.tfMethod.text = NSLocalizedString(@"CheckPay_PayMethod_Card", @"CheckPay_PayMethod_Card");
            break;
        default: {
            svcCurrency *c = (svcCurrency *)[self.check.AdditionalCurrencies objectAtIndex:_selectedCurrency];
            self.tfMethod.text = c.Name;
            break;
        }
    }
    [self validate];
    [self loadParameters];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = nil;
    if (textField == self.tfMethod)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    else
    {
        UIParameterTextField *ptf = (UIParameterTextField *)textField;
        for (int idx = 0; idx < [_selectedCurrencyParameters count]; idx++)
        {
            if ([ptf.parameter.Name isEqualToString:[(svcParameter *)[_selectedCurrencyParameters objectAtIndex:idx] Name]])
            {
                indexPath = [NSIndexPath indexPathForRow:idx inSection:2];
                break;
            }
        }
    }
    [self.tblCheck.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = str;
    if ([textField isKindOfClass:[UIParameterTextField class]])
    {
        [(UIParameterTextField *)textField parameter].DefaultValue = str;
    }
    [self validate];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self validate];
    return YES;
}

#pragma mark CardsViewControllerDelegate

- (void)cardSelected:(svcCard *)card controller:(UIViewController *)controller
{
    _card = card;
    [self enterCVC];
}

#pragma mark EnterCVCDelegate

-(void)finishEnterCVC:(UIViewController *)controller cvcEntered:(BOOL)cvcEntered cvcValue:(NSString*)cvcValue
{
    _needToShowDoneButton = NO;
    if (cvcEntered)
    {
        [(EnterCVCViewController_iPhone *)controller removeFromViewController];
        _cvc = cvcValue;
        [self payCheck];
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

@end
