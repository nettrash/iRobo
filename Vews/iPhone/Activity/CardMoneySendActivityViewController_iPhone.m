//
//  CardSendMoneyActivityViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardMoneySendActivityViewController_iPhone.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"
#import "NSNumber+Currency.h"
#import "NSString+RegEx.h"
#import "EnterCVCViewController_iPhone.h"
#import "UIViewController+KeyboardExtensions.h"

@interface CardMoneySendActivityViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextField *tfFromCard;
@property (nonatomic, retain) IBOutlet UITextField *tfToCard;
@property (nonatomic, retain) IBOutlet UITextField *tfSumm;
@property (nonatomic, retain) IBOutlet UILabel *lblCommission;
@property (nonatomic, retain) UIPickerView *pvCards;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) NSString *toCardNumber;
@property (nonatomic, retain) EnterCVCViewController_iPhone *cvcView;
@property (nonatomic, retain) IBOutlet UIImageView *imgFormBack;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityWait;
@property (nonatomic, retain) IBOutlet UILabel *lblWaitText;

@end

@implementation CardMoneySendActivityViewController_iPhone

@synthesize delegate = _delegate;
@synthesize card = _card;
@synthesize tfFromCard = _tfFromCard;
@synthesize tfToCard = _tfToCard;
@synthesize tfSumm = _tfSumm;
@synthesize lblCommission = _lblCommission;
@synthesize pvCards = _pvCards;
@synthesize cards = _cards;
@synthesize closeButton = _closeButton;
@synthesize doneButton = _doneButton;
@synthesize toCardNumber = _toCardNumber;
@synthesize cvcView = _cvcView;
@synthesize imgFormBack = _imgFormBack;
@synthesize activityWait = _activityWait;
@synthesize lblWaitText = _lblWaitText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil formType:(MoneySendFormType)formType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _formType = formType;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tfSumm.text = @"";
    [self updateCommission];
    self.toCardNumber = @"";
    
    _needToShowDoneButton = YES;

    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton.frame = CGRectMake(0, 163, 106, 53);
    self.doneButton.adjustsImageWhenHighlighted = NO;
    
    [self.doneButton setTitle:NSLocalizedString(@"...", @"...") forState:UIControlStateApplication];
    [self.doneButton setTitle:NSLocalizedString(@"...", @"...") forState:UIControlStateDisabled];
    [self.doneButton setTitle:NSLocalizedString(@"...", @"...") forState:UIControlStateHighlighted];
    [self.doneButton setTitle:NSLocalizedString(@"...", @"...") forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"...", @"...") forState:UIControlStateReserved];
    [self.doneButton setTitle:NSLocalizedString(@"...", @"...") forState:UIControlStateSelected];
    
    [self.doneButton addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self validate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switch (_formType) {
        case MoneySendFormTypeSendOutside: {
            self.tfFromCard.text = self.card.card_Number;
            self.tfFromCard.enabled = NO;
            [self.tfToCard becomeFirstResponder];
            break;
        }
        case MoneySendFormTypeTransferBetween: {
            self.tfToCard.text = self.card.card_Number;
            self.tfToCard.enabled = NO;
            if (self.cards && [self.cards count] > 0)
                self.tfFromCard.text = [(svcCard *)[self.cards objectAtIndex:0] card_Number];
            self.pvCards = [[UIPickerView alloc] init];
            self.pvCards.dataSource = self;
            self.pvCards.delegate = self;
            [self.tfFromCard setInputView:self.pvCards];
            [self.tfFromCard becomeFirstResponder];
            break;
        }
        default:
            break;
    }
    
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
    
    _keyboardIsShowing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)keyboardWillShow:(NSNotification *)note
{
	if (_keyboardIsShowing) return;
    if (_needToShowDoneButton)
        [self addDoneButtonToNumberPadKeyboard];
    else
        [self removeDoneButtonFromNumberPadKeyboard];
	_keyboardIsShowing = YES;
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

- (IBAction)btnClose_Click:(id)sender
{
    self.closeButton.enabled = NO;
    [self.tfFromCard resignFirstResponder];
    [self.tfToCard resignFirstResponder];
    [self.tfSumm resignFirstResponder];
    [self.delegate sendMoneyActivityFinished:self];
}

- (IBAction)btnDone_Click:(id)sender
{
    self.tfFromCard.enabled = NO;
    self.tfToCard.enabled = NO;
    self.tfSumm.enabled = NO;
    
    self.cvcView = [[EnterCVCViewController_iPhone alloc] initWithNibName:@"EnterCVCViewController_iPhone" bundle:nil];
    self.cvcView.delegate = self;
    [self.doneButton removeTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton addTarget:self.cvcView action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.cvcView performSelector:@selector(addToViewController:) withObject:self afterDelay:.1];
}

- (void)startOp:(NSString *)cvc
{
    int fromCardId = 0;
    int toCardId = 0;
    NSString *toCardNumber = @"";
    
    switch (_formType) {
        case MoneySendFormTypeTransferBetween: {
            svcCard *c = (svcCard *)[self.cards objectAtIndex:[self.pvCards selectedRowInComponent:0]];
            fromCardId = c.card_Id;
            toCardId = self.card.card_Id;
            break;
        }
        case MoneySendFormTypeSendOutside: {
            fromCardId = self.card.card_Id;
            toCardNumber = self.toCardNumber;
            break;
        }
        default:
            [self btnClose_Click:nil];
            return;
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc Card2CardTransfer:self action:@selector(startOpHandler:) UNIQUE:[app.userProfile uid] fromCardId:fromCardId toCardId:toCardId toCardNumber:toCardNumber summ:[NSDecimalNumber decimalNumberWithString:self.tfSumm.text] fromCardCVC:cvc];
}

- (void)startOpHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result && ![resp.OpKey isEqualToString:@""])
        {
            _opKey = resp.OpKey;
            [self performSelector:@selector(checkOperation) withObject:nil afterDelay:1];
            return;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Card2CardTransferStartErrorTitle", @"Card2CardTransferStartErrorTitle") message:NSLocalizedString(@"Card2CardTransferStartErrorMessage", @"Card2CardTransferStartErrorMessage") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
    [self btnClose_Click:nil];
}

- (void)checkOperation
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetOperationState:self action:@selector(checkOperationHandle:) UNIQUE:[app.userProfile uid] OpKey:_opKey];
}

- (void)checkOperationHandle:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.operationState.inputDone)
            {
                //OK и возврат
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Card2CardTransferSuccessTitle", @"Card2CardTransferSuccessTitle") message:NSLocalizedString(@"Card2CardTransferSuccessMessage", @"Card2CardTransferSuccessMessage") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
                [alert show];
                [self btnClose_Click:nil];
                return;
            }
            if ([resp.operationState.Process isEqualToString:@"Cancel"])
            {
                //Отмена и возврат
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Card2CardTransferStartErrorTitle", @"Card2CardTransferStartErrorTitle") message:NSLocalizedString(@"Card2CardTransferStartErrorMessage", @"Card2CardTransferStartErrorMessage") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
                [alert show];
                [self btnClose_Click:nil];
                return;
            }
            if ([resp.operationState.Process isEqualToString:@"Input"] && resp.operationState.Redirect)
            {
                //Показываем WebView
                UIWebView *wv3D = [[UIWebView alloc] initWithFrame:self.view.frame];
                wv3D.scalesPageToFit = YES;
                NSURL *URL = [NSURL URLWithString:resp.operationState.Redirect.Url];
                NSURLRequest *rq = [NSURLRequest requestWithURL:URL];
                wv3D.delegate = self;
                [wv3D loadRequest:rq];
                [self.view addSubview:wv3D];
                [self.view bringSubviewToFront:wv3D];
            }
        }
    }
    [self performSelector:@selector(checkOperation) withObject:nil afterDelay:5];
}

- (void)updateCommission
{
    int summa = [self.tfSumm.text intValue];
    double comission = summa * 0.0199f;
    if (comission < 50) comission = 50;
    NSNumber *nComission = [NSNumber numberWithDouble:comission];
    self.lblCommission.text = [NSString stringWithFormat:NSLocalizedString(@"c2c_comission", @""), [nComission numberWithCurrency]];
}

- (BOOL)isValidCC:(NSString *)number
{
    NSMutableArray *sumTable = [NSMutableArray arrayWithObjects:
                                [NSMutableArray arrayWithObjects:
                                 [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], nil],
                                [NSMutableArray arrayWithObjects:
                                 [NSNumber numberWithInt:0], [NSNumber numberWithInt:2], [NSNumber numberWithInt:4], [NSNumber numberWithInt:6], [NSNumber numberWithInt:8], [NSNumber numberWithInt:1], [NSNumber numberWithInt:3], [NSNumber numberWithInt:5], [NSNumber numberWithInt:7], [NSNumber numberWithInt:9], nil], nil];
    int sum = 0, flip = 0;
    
    for (int i = (int)(number.length - 1); i >= 0; i--) {
        int n = [[number substringWithRange:NSMakeRange(i, 1)] intValue];
        sum += [(NSNumber *)[(NSMutableArray *)[sumTable objectAtIndex:(flip++ & 0x1)] objectAtIndex:n] intValue];
    }
    return sum % 10 == 0;
}

- (BOOL)validate
{
    BOOL bValidSumma = [self.tfSumm.text intValue] > 0 && [self.tfSumm.text intValue] < 75001;
    
    if (!bValidSumma)
        self.lblCommission.text = NSLocalizedString(@"Card2CardSummaLimit", @"Card2CardSummaLimit");
    BOOL bValidToCard = YES;
    
    if (_formType == MoneySendFormTypeSendOutside)
    {
        bValidToCard = self.toCardNumber ? [self.toCardNumber length] == 16 && [self.toCardNumber checkFormat:@"^\\d{16}$"] && [self isValidCC:self.toCardNumber] : NO;
    }
    
    if (bValidSumma && bValidToCard)
    {
        [self.doneButton setTitle:NSLocalizedString(@"PAY", @"") forState:UIControlStateApplication];
        [self.doneButton setTitle:NSLocalizedString(@"PAY", @"") forState:UIControlStateDisabled];
        [self.doneButton setTitle:NSLocalizedString(@"PAY", @"") forState:UIControlStateHighlighted];
        [self.doneButton setTitle:NSLocalizedString(@"PAY", @"") forState:UIControlStateNormal];
        [self.doneButton setTitle:NSLocalizedString(@"PAY", @"") forState:UIControlStateReserved];
        [self.doneButton setTitle:NSLocalizedString(@"PAY", @"") forState:UIControlStateSelected];
        [self.doneButton setBackgroundColor:[UIColor colorWithRed:130.0/255.0 green:203.0/255.0 blue:161.0/255.0 alpha:1]];
        self.doneButton.enabled = YES;
    }
    else
    {
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateApplication];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateDisabled];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateHighlighted];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateNormal];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateReserved];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateSelected];
        [self.doneButton setBackgroundColor:[UIColor clearColor]];
        self.doneButton.enabled = NO;
    }
    
    return bValidSumma && bValidToCard;
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.cards)
    {
        return [self.cards count];
    }
    else
    {
        return 0;
    }
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [(svcCard *)[self.cards objectAtIndex:row] card_Number];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.tfFromCard.text = [(svcCard *)[self.cards objectAtIndex:row] card_Number];
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.tfFromCard)
    {
        _needToShowDoneButton = NO;
        [self removeDoneButtonFromNumberPadKeyboard];
    }
    else
        _needToShowDoneButton = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.tfFromCard)
        return NO;
    else
    {
        if (textField == self.tfSumm)
        {
            self.tfSumm.text = str;
            [self updateCommission];
            [self validate];
            return NO;
        }
        if (textField == self.tfToCard)
        {
            self.toCardNumber = [self.toCardNumber stringByReplacingCharactersInRange:range withString:string];
            NSUInteger len = [self.toCardNumber length];
            if (len < 8)
            {
                self.tfToCard.text = self.toCardNumber;
                [self validate];
                return NO;
            }
            NSRange r;
            NSString *s = @"******";
            if (len > 7 && len < 13) {
                r = NSMakeRange(6, len - 7);
                s = @"";
                for (int i = 0; i < len - 7; i++)
                    s = [s stringByAppendingString:@"*"];
            } else {
                r = NSMakeRange(6, 6);
            }
            self.tfToCard.text = [self.toCardNumber stringByReplacingCharactersInRange:r withString:s];
            [self validate];
            return NO;
        }
        return YES;
    }
}

#pragma mark EnterCVCDelegate

-(void)finishEnterCVC:(UIViewController *)controller cvcEntered:(BOOL)cvcEntered cvcValue:(NSString*)cvcValue
{
    if (cvcEntered)
    {
        _needToShowDoneButton = NO;

        [(EnterCVCViewController_iPhone *)controller removeFromViewController];
        
        [UIView animateWithDuration:0.5
                              delay:1.0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             self.imgFormBack.hidden = YES;
                             self.closeButton.hidden = YES;
                             self.tfFromCard.hidden = YES;
                             self.tfToCard.hidden = YES;
                             self.tfSumm.hidden = YES;
                             self.lblCommission.hidden = YES;
                             [self hideKeyboard];
                             [self.activityWait startAnimating];
                             self.lblWaitText.hidden = NO;
                         }
                         completion:^(BOOL finished){
                             [self performSelector:@selector(startOp:) withObject:cvcValue afterDelay:.1];
                         }];
    }
    else
    {
        [self performSelector:@selector(btnClose_Click:) withObject:nil afterDelay:.1];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *slURL = webView.request.URL.absoluteString;
    if ([slURL hasPrefix:@"https://misc.roboxchange.com/External/iPhone/redirectToShop.aspx"]) {
        webView.hidden = YES;
        [webView loadHTMLString:@"" baseURL:nil];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *slURL = webView.request.URL.absoluteString;
    if ([slURL hasPrefix:@"https://misc.roboxchange.com/External/iPhone/redirectToShop.aspx"]) {
        webView.hidden = YES;
        [webView loadHTMLString:@"" baseURL:nil];
    }
}

@end
