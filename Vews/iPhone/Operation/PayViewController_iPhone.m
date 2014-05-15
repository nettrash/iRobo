//
//  PayViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 07.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "PayViewController_iPhone.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "svcParameter.h"
#import "UIParameterTextField.h"
#import "NSString+RegEx.h"
#import "CardsViewController_iPhone.h"
#import "EnterCVCViewController_iPhone.h"
#import "OperationStateViewController_iPhone.h"
#import "UIViewController+KeyboardExtensions.h"
#import "NSNumber+Currency.h"

@interface PayViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblPayment;
@property (nonatomic, retain) UITextField *tfSumma;
@property (nonatomic, retain) EnterCVCViewController_iPhone *cvcView;
@property (nonatomic, retain) UIButton *doneButton;

@end

@implementation PayViewController_iPhone

@synthesize delegate = _delegate;
@synthesize tblPayment = _tblPayment;
@synthesize tfSumma = _tfSumma;
@synthesize cvcView = _cvcView;
@synthesize doneButton = _doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTopCurrency:(svcTopCurrency *)currency
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstInitialize = NO;
        _isRefreshing = NO;
        _parameters = nil;
        _topCurrency = currency;
        _currencyLabel = _topCurrency.Label;
        _card = nil;
        _cvc = nil;
        _needToShowDoneButton = NO;
        _comissionViewController = nil;
        _summa = [NSDecimalNumber decimalNumberWithString:@"0,00"];
        self.navigationItem.title = [_topCurrency.Name uppercaseString];

        self.tfSumma = [[UITextField alloc] initWithFrame:CGRectMake(15, 6, 285, 30)];
        self.tfSumma.adjustsFontSizeToFitWidth = YES;
        self.tfSumma.textColor = [UIColor darkGrayColor];
        self.tfSumma.keyboardType = UIKeyboardTypeDecimalPad;
        self.tfSumma.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.tfSumma.delegate = self;
        self.tfSumma.text = @"0,00";
        [self.tfSumma setTextAlignment:NSTextAlignmentRight];
        self.tfSumma.clearsOnBeginEditing = YES;
    }
    return self;
}

- (void)initWithTopCurrency
{
    NSArray *prms = [_topCurrency.Parameters componentsSeparatedByString:@";"];
    if (prms && prms != nil && [prms count] > 0)
    {
        for (int idx = 0; idx < [_parameters count]; idx++)
        {
            if (idx >= [prms count]) continue;
            if ([(NSString *)[prms objectAtIndex:idx] isEqualToString:@""]) continue;
            NSArray *pv = [(NSString *)[prms objectAtIndex:idx] componentsSeparatedByString:@":"];
            if (pv && pv != nil && [pv count] == 2 && idx < [_parameters count])
            {
                svcParameter *p = (svcParameter *)[_parameters objectAtIndex:idx];
                p.DefaultValue = (NSString *)[pv objectAtIndex:1];
            }
        }
    }
    if ([_topCurrency.OutPossibleValues rangeOfString:@";"].location != NSNotFound)
    {
        UIPickerView *pv = [[UIPickerView alloc] init];
        pv.dataSource = self;
        pv.delegate = self;
        self.tfSumma.inputView = pv;
        self.tfSumma.clearsOnBeginEditing = NO;
        self.tfSumma.text = (NSString *)[[_topCurrency.OutPossibleValues componentsSeparatedByString:@";"] objectAtIndex:0];
    }
    [self.tfSumma performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1];
    [self validate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    self.tblPayment.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20);
    [self.view addSubview:self.tblPayment.view];

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

    if (!_firstInitialize)
        [self performSelector:@selector(getParameters:) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
	CGRect frame = self.tblPayment.view.frame;
	frame.size.height -= [_keyboardHeight floatValue];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	
	self.tblPayment.view.frame = frame;
	
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
        CGRect frame = self.tblPayment.view.frame;
        frame.size.height += [_keyboardHeight floatValue];
		
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
		
        self.tblPayment.view.frame = frame;
		
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

- (void)getParameters:(id)sender
{
    _isRefreshing = YES;
    
    [self.tblPayment.tableView reloadData];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetParameters:self action:@selector(getParametersHandler:) UNIQUE:[app.userProfile uid] currency:_currencyLabel];
}

- (void)getParametersHandler:(id)response
{
    _isRefreshing = NO;
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            _parameters = resp.parameters;
            
            if (_topCurrency != nil && !_firstInitialize)
            {
                _firstInitialize = YES;
                self.tblPayment.refreshControl = nil;
                [self initWithTopCurrency];
            }
        }
    }
    [self.tblPayment.tableView reloadData];
}

- (void)validate
{
    BOOL bValidSumma = NO;
    NSDecimalNumber *summa = [NSDecimalNumber decimalNumberWithString:[self.tfSumma.text stringByReplacingOccurrencesOfString:@"," withString:@"."]];

    if (_topCurrency == nil || _topCurrency.OutPossibleValues == nil || [_topCurrency.OutPossibleValues isEqualToString:@""])
        bValidSumma = YES;
    else
    {
        NSArray *groups = [_topCurrency.OutPossibleValues componentsSeparatedByString:@";"];
        for (NSString *group in groups) {
            if (group == nil || [group isEqualToString:@""])
            {
                bValidSumma = YES;
                break;
            }
            else
            {
                NSArray *min_max = [group componentsSeparatedByString:@"-"];
                if ([min_max count] == 1)
                {
                    if ([summa compare:[NSDecimalNumber decimalNumberWithString:(NSString *)[min_max objectAtIndex:0]]] == NSOrderedSame)
                    {
                        bValidSumma = YES;
                        break;
                    }
                }
                else
                {
                    NSString *sMin = [min_max objectAtIndex:0];
                    NSString *sMax = [min_max objectAtIndex:1];
                    NSDecimalNumber *min = [NSDecimalNumber decimalNumberWithString:sMin];
                    NSDecimalNumber *max = [NSDecimalNumber decimalNumberWithString:sMax];
                    NSComparisonResult minRes = [summa compare:min];
                    NSComparisonResult maxRes = [summa compare:max];
                    if ((minRes == NSOrderedDescending || minRes == NSOrderedSame) && (maxRes == NSOrderedAscending || maxRes == NSOrderedSame))
                    {
                        bValidSumma = YES;
                        break;
                    }
                }
            }
        }
    }
    
    BOOL bValidParams = YES;
    
    for (svcParameter *p in _parameters)
    {
        if (!p.DefaultValue || p.DefaultValue == nil || [p.DefaultValue isEqualToString:@""] || ![p.DefaultValue checkFormat:p.Format])
            bValidParams = NO;
    }
    
    if (bValidSumma && bValidParams)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PayButton_Title", @"PayButton_Title") style:UIBarButtonItemStyleDone target:self action:@selector(chooseCard:)];
    else
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)startOperation:(NSString *)cvc
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"StartOperation_WaitMessage", @"StartOperation_WaitMessage")];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    for (svcParameter *p in _parameters)
    {
        [a addObject:[NSString stringWithFormat:@"%@:%@", p.Name, p.DefaultValue]];
    }
    NSString *prms = [a componentsJoinedByString:@";"];
    
    [svc StartOperation:self action:@selector(startOperationHandler:) UNIQUE:[app.userProfile uid] cardId:[_card card_Id] summa:_summa currency:_currencyLabel parameters:prms CVC:cvc];
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

- (void)chooseCard:(id)sender
{
    _summa = [NSDecimalNumber decimalNumberWithString:[self.tfSumma.text stringByReplacingOccurrencesOfString:@"," withString:@"."]];
    CardsViewController_iPhone *cv = [[CardsViewController_iPhone alloc] initWithNibName:@"CardsViewController_iPhone" bundle:nil showUnauthorizedCards:NO withFormType:CardsViewFormTypeSelectView];
    cv.delegate = self;
    [self.navigationController pushViewController:cv animated:YES];
}

- (void)enterCVC
{
    _needToShowDoneButton = YES;
    [self.cvcView performSelector:@selector(addToViewController:) withObject:self.navigationController.topViewController afterDelay:.1];
}

- (void)showComission
{
    [self hideKeyboard];
    _comissionViewController = [[ComissionViewController_iPhone alloc] initWithNibName:@"ComissionViewController_iPhone" bundle:nil currency:_currencyLabel OutSumma:_summa cardId:[_card card_Id]];
    _comissionViewController.delegate = self;
    [_comissionViewController performSelector:@selector(addToViewController:) withObject:self.navigationController.topViewController afterDelay:.1];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (_isRefreshing)
                return 1;
            else
                if (_parameters && _parameters != nil && [_parameters count] > 0)
                    return [_parameters count];
                else
                    return 0;
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"PaymentSection_Parameters", @"PaymentSection_Parameters");
        case 1:
            return NSLocalizedString(@"PaymentSection_Summa", @"PaymentSection_Summa");
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"ParameterRefresh";
    svcParameter *prm = nil;
    if (!_isRefreshing)
    {
        if (_parameters && _parameters != nil && [_parameters count] > 0)
        {
            prm = (svcParameter *)[_parameters objectAtIndex:indexPath.row];
            identifier = prm.Name;
        }
        else
        {
            identifier = @"ParameterRefreshFail";
        }
    }
    if (indexPath.section == 1)
        identifier = @"PaymentSummaCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    BOOL dequeued = YES;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        dequeued = NO;
    }
    
    switch (indexPath.section) {
        case 0: {
            if (_isRefreshing)
            {
                if (!dequeued)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                ai.hidesWhenStopped = YES;
                [ai startAnimating];
                cell.accessoryView = ai;
                cell.textLabel.text = NSLocalizedString(@"Payment_Parameter_Refresh_Title", @"Payment_Parameter_Refresh_Title");
                cell.detailTextLabel.text = NSLocalizedString(@"Payment_Parameter_Refresh_Details", @"Payment_Parameter_Refresh_Details");
            }
            else
            {
                if (_parameters && _parameters != nil && [_parameters count] > 0)
                {
                    if (!dequeued && ([prm.Type isEqualToString:@"Text"] || [prm.Type isEqualToString:@"Options"]))
                    {
                        UIParameterTextField *tf = [[UIParameterTextField alloc] initWithFrame:CGRectMake(15, 6, 285, 30) andParameter:prm];
                        tf.delegate = self;
                        [cell addSubview:tf];
                    }
                    if ([prm.Type isEqualToString:@"Check"])
                    {
                        cell.textLabel.text = [prm.Label uppercaseString];
                        if ([[prm.DefaultValue uppercaseString] isEqualToString:@"TRUE"])
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        else
                            cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                }
                else
                {
                    if (!dequeued)
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.textLabel.text = NSLocalizedString(@"Payment_Parameter_Refresh_Fail_Title", @"Payment_Parameter_Refresh_Fail_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"Payment_Parameter_Refresh_Fail_Details", @"Payment_Parameter_Refresh_Fail_Details");
                }
            }
            break;
        }
        case 1: {
            if (!dequeued)
            {
                cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell addSubview:self.tfSumma];
            }
            break;
        }
        default:
            return nil;
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = nil;
    if (textField == self.tfSumma)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    else
    {
        UIParameterTextField *ptf = (UIParameterTextField *)textField;
        for (int idx = 0; idx < [_parameters count]; idx++)
        {
            if ([ptf.parameter.Name isEqualToString:[(svcParameter *)[_parameters objectAtIndex:idx] Name]])
            {
                indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                break;
            }
        }
    }
    [self.tblPayment.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
        if ([_card card_IsOCEAN])
            [self startOperation:cvcValue];
        else
            [self showComission];
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

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int cnt = 0;
    for (NSString *s in [_topCurrency.OutPossibleValues componentsSeparatedByString:@";"])
    {
        if (s && s != nil && ![s isEqualToString:@""]) cnt++;
    }
    return cnt;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    NSDecimalNumber *n = [NSDecimalNumber decimalNumberWithString:(NSString *)[[_topCurrency.OutPossibleValues componentsSeparatedByString:@";"] objectAtIndex:row]];
    return [n numberWithCurrency];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.tfSumma.text = (NSString *)[[_topCurrency.OutPossibleValues componentsSeparatedByString:@";"] objectAtIndex:row];
    [self validate];
}

@end
