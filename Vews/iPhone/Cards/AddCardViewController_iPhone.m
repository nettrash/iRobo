//
//  AddCardViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 16.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "AddCardViewController_iPhone.h"
#import "SWRevealViewController.h"
#import "UIViewController+KeyboardExtensions.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"

@interface AddCardViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblAddCard;

@property (nonatomic, retain) NSString *cardNumber;
@property (nonatomic, retain) NSString *cardHolder;
@property (nonatomic, retain) NSString *cardName;
@property (nonatomic) NSInteger cardExpiryMonth;
@property (nonatomic) NSInteger cardExpiryYear;
@property (nonatomic, retain) UITextField *tfCardNumber;
@property (nonatomic, retain) UITextField *tfCardHolder;
@property (nonatomic, retain) UITextField *tfCardExpiry;
@property (nonatomic, retain) UITextField *tfCardName;
@property (nonatomic, retain) UIPickerView *pvExpiry;

@end

@implementation AddCardViewController_iPhone

@synthesize tblAddCard = _tblAddCard;
@synthesize cardNumber = _cardNumber;
@synthesize cardHolder = _cardHolder;
@synthesize cardName = _cardName;
@synthesize cardExpiryMonth = _cardExpiryMonth;
@synthesize cardExpiryYear = _cardExpiryYear;
@synthesize tfCardNumber = _tfCardNumber;
@synthesize tfCardHolder = _tfCardHolder;
@synthesize tfCardExpiry = _tfCardExpiry;
@synthesize tfCardName = _tfCardName;
@synthesize pvExpiry = _pvExpiry;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"AddCard_Title", @"AddCard_Title");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addCard:)];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        self.tfCardNumber = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfCardNumber.adjustsFontSizeToFitWidth = YES;
        self.tfCardNumber.textColor = [UIColor darkGrayColor];
        self.tfCardNumber.placeholder = NSLocalizedString(@"AddCard_Number_PlaceHolder", @"AddCard_Number_PlaceHolder");;
        self.tfCardNumber.keyboardType = UIKeyboardTypeNumberPad;
        self.tfCardNumber.delegate = self;

        self.tfCardHolder = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfCardHolder.adjustsFontSizeToFitWidth = YES;
        self.tfCardHolder.textColor = [UIColor darkGrayColor];
        self.tfCardHolder.placeholder = NSLocalizedString(@"AddCard_Holder_PlaceHolder", @"AddCard_Holder_PlaceHolder");
        self.tfCardHolder.keyboardType = UIKeyboardTypeASCIICapable;
        self.tfCardHolder.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.tfCardHolder.delegate = self;

        self.tfCardExpiry = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfCardExpiry.adjustsFontSizeToFitWidth = YES;
        self.tfCardExpiry.textColor = [UIColor darkGrayColor];
        self.tfCardExpiry.placeholder = NSLocalizedString(@"AddCard_Expiry_PlaceHolder", @"AddCard_Expiry_PlaceHolder");
        self.pvExpiry = [[UIPickerView alloc] init];
        self.pvExpiry.dataSource = self;
        self.pvExpiry.delegate = self;
        [self.tfCardExpiry setInputView:self.pvExpiry];
        self.tfCardExpiry.delegate = self;

        self.tfCardName = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfCardName.adjustsFontSizeToFitWidth = YES;
        self.tfCardName.textColor = [UIColor darkGrayColor];
        self.tfCardName.placeholder = NSLocalizedString(@"AddCard_Name_PlaceHolder", @"AddCard_Name_PlaceHolder");
        self.tfCardName.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.tblAddCard action:@selector(hideKeyboard)];
    [self.tblAddCard.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tblAddCard.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 16, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 16);
    [self.view addSubview:self.tblAddCard.view];

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

- (void)cardScan:(id)sender
{
    SWRevealViewController *reveal = [self revealViewController];
    CardIOPaymentViewController *cardInfo = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    cardInfo.appToken = @"fd16bbca2d4f4dabaf736acc67a7243b";
    cardInfo.useCardIOLogo = YES;
    cardInfo.suppressScanConfirmation = YES;
    cardInfo.collectCVV = YES;
    cardInfo.collectExpiry = YES;
    cardInfo.languageOrLocale = @"ru";
    cardInfo.disableBlurWhenBackgrounding = YES;
    cardInfo.disableManualEntryButtons = YES;
    [reveal presentViewController:cardInfo animated:YES completion:nil];
}

- (void)addCard:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"RegisterCard_WaitMessage", @"RegisterCard_WaitMessage")];
    [self hideKeyboard];
    [self performSelector:@selector(registerCard) withObject:nil afterDelay:1];
}

- (void)registerCard
{
    NSString *cType = [self.cardNumber hasPrefix:@"4"] ? @"VISA" : @"MASTERCARD";
    NSString *cName = self.cardName;
    if (!cName || cName == nil || [cName length] < 1 || [cName isEqualToString:@""])
    {
        cName = [NSString stringWithFormat:@"%@ *%@", cType, [self.cardNumber substringWithRange:NSMakeRange(self.cardNumber.length - 4, 4)]];
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    NSString *ccHolder = self.cardHolder;
    if (!ccHolder || ccHolder != nil || [ccHolder isEqualToString:@""])
        ccHolder = @"CARD HOLDER";
    [svc RegisterCard:self action:@selector(registerCardHandler:) UNIQUE:[app.userProfile uid] cardName:cName cardNumber:self.cardNumber cardType:cType cardYear:(int)self.cardExpiryYear cardMonth:(int)self.cardExpiryMonth cardHolder:self.cardHolder];
}

- (void)registerCardHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            CardAuthorizeViewController_iPhone *a =  [[CardAuthorizeViewController_iPhone alloc] initWithNibName:@"CardAuthorizeViewController_iPhone" bundle:nil];
            a.card_Id = resp.card_Id;
            a.card_InAuthorize = NO;
            a.delegate = self;
            [self.navigationController pushViewController:a animated:YES];
        }
        else
        {
            if (resp.showerror)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RegisterCard_Error_Title", @"RegisterCard_Error_Title") message:resp.errortext delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RegisterCard_Error_Title", @"RegisterCard_Error_Title") message:NSLocalizedString(@"RegisterCard_Error_Message", @"RegisterCard_Error_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RegisterCard_Error_Title", @"RegisterCard_Error_Title") message:NSLocalizedString(@"RegisterCard_Error_Message", @"RegisterCard_Error_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
        [alert show];
    }
}

- (void)keyboardWillShow : (NSNotification *) note
{
	if (_keyboardIsShowing) return;
    
    CGRect keyboardBounds;
	
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
	
    _keyboardHeight = [NSNumber numberWithFloat:keyboardBounds.size.height];
	
	_keyboardIsShowing = YES;
	
	CGRect frame = self.tblAddCard.view.frame;
	frame.size.height -= [_keyboardHeight floatValue];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	
	self.tblAddCard.view.frame = frame;
	
	[UIView commitAnimations];
}

- (void)keyboardDidShow : (NSNotification *) note
{
}

- (void)keyboardWillHide : (NSNotification *) note
{
    if (_keyboardIsShowing) {
        _keyboardIsShowing = NO;
        CGRect frame = self.tblAddCard.view.frame;
        frame.size.height += [_keyboardHeight floatValue];
		
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
		
        self.tblAddCard.view.frame = frame;
		
        [UIView commitAnimations];
	}
}

- (BOOL)checkFormat : (NSString *)text withFormat : (NSString *)format
{
    NSError *error;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:[format stringByReplacingOccurrencesOfString:@"\n" withString:@""] options:NSRegularExpressionCaseInsensitive error:&error];
    
    return [regExp numberOfMatchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, [text length])] > 0;
}

- (BOOL)isValidCC : (NSString *) number
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

- (void)showCardExpiry
{
    if (self.cardExpiryMonth > 0 && self.cardExpiryYear == 0) {
        _tfCardExpiry.text = [NSString stringWithFormat:@"%02li/", (long)self.cardExpiryMonth];
    }
    if (self.cardExpiryMonth == 0 && self.cardExpiryYear > 0) {
        _tfCardExpiry.text = [NSString stringWithFormat:@"/%02li", (long)self.cardExpiryYear];
    }
    if (self.cardExpiryMonth > 0 && self.cardExpiryYear > 0) {
        _tfCardExpiry.text = [NSString stringWithFormat:@"%02li/%li", (long)self.cardExpiryMonth, (long)self.cardExpiryYear];
    }
}

- (BOOL)checkExpire
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger m = [components month];
    NSInteger y = [components year];
    return ((self.cardExpiryYear > y) && self.cardExpiryMonth > 0 && self.cardExpiryMonth < 13) || ((self.cardExpiryYear == y) && self.cardExpiryMonth < 13 && self.cardExpiryMonth >= m);
}

- (void)validate
{
    @try {
        /*Проверяем номер карты*/
        BOOL vCardNumber = self.cardNumber ? [self.cardNumber length] == 16 && [self checkFormat: self.cardNumber withFormat:@"^\\d{16}$"] && [self isValidCC:self.cardNumber] : NO;
        
        /*Проверяем месяц и год*/
        BOOL vExp = [self checkExpire];
        
        /*Проверяем владельца карты*/
        //BOOL vCardHolder = self.cardHolder ? [self.cardHolder length] > 2 && [self.cardHolder rangeOfString:@" "].location != NSNotFound && [self checkFormat: self.cardHolder withFormat:@"^[A-Z][A-Z ]{1,24}[A-Z]$"] : NO;
        
        self.navigationItem.rightBarButtonItem.enabled = vCardNumber && vExp;// && vCardHolder;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    @finally {
    }
}

#pragma mark CardIOPaymentViewControllerDelegate

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    SWRevealViewController *reveal = [self revealViewController];
    [reveal dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    SWRevealViewController *reveal = [self revealViewController];
    if (cardInfo.scanned)
    {
        self.cardNumber = cardInfo.cardNumber;
        self.tfCardNumber.text = self.cardNumber;
        if (cardInfo.expiryMonth != 0)
            self.cardExpiryMonth = cardInfo.expiryMonth;
        if (cardInfo.expiryYear != 0)
            self.cardExpiryYear = cardInfo.expiryYear;
        [self showCardExpiry];
        [self.tfCardHolder becomeFirstResponder];
        [self validate];
    }
    [reveal dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"AddCard_Number", @"AddCard_Number");
        case 1:
            return NSLocalizedString(@"AddCard_Holder", @"AddCard_Holder");
        case 2:
            return NSLocalizedString(@"AddCard_Expiry", @"AddCard_Expiry");
        case 3:
            return NSLocalizedString(@"AddCard_Name", @"AddCard_Name");
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:@"AddCardItemCell"];
    BOOL dequeued = YES;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AddCardItemCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        dequeued = NO;
    }
    
    switch (indexPath.section) {
        case 0: {
            self.tfCardNumber.text = self.cardNumber;
            if (!dequeued)
            {
                [cell addSubview:self.tfCardNumber];
                UIButton *btnScan = [UIButton buttonWithType:UIButtonTypeContactAdd];
                [btnScan addTarget:self action:@selector(cardScan:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = btnScan;
            }
            break;
        }
        case 1: {
            self.tfCardHolder.text = self.cardHolder;
            if (!dequeued)
                [cell addSubview:self.tfCardHolder];
            break;
        }
        case 2: {
            if (!dequeued)
                [cell addSubview:self.tfCardExpiry];
            break;
        }
        case 3: {
            self.tfCardName.text = self.cardName;
            if (!dequeued)
                [cell addSubview:self.tfCardName];
            break;
        }
        default:
            return nil;
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:8];
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
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return 12;
        default:
            return 25;
    }
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0: {
            switch (row) {
                case 0:
                    return NSLocalizedString(@"jan", @"jan");
                case 1:
                    return NSLocalizedString(@"feb", @"feb");
                case 2:
                    return NSLocalizedString(@"mar", @"mar");
                case 3:
                    return NSLocalizedString(@"apr", @"apr");
                case 4:
                    return NSLocalizedString(@"may", @"may");
                case 5:
                    return NSLocalizedString(@"jun", @"jun");
                case 6:
                    return NSLocalizedString(@"jul", @"jul");
                case 7:
                    return NSLocalizedString(@"aug", @"aug");
                case 8:
                    return NSLocalizedString(@"sep", @"sep");
                case 9:
                    return NSLocalizedString(@"okt", @"okt");
                case 10:
                    return NSLocalizedString(@"nov", @"nov");
                case 11:
                    return NSLocalizedString(@"dec", @"dec");
                default:
                    return @"";
            }
        }
        case 1: {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar/*NSCalendarIdentifierGregorian*/];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
            return [NSString stringWithFormat:@"%i", [components year] + row];
        }
        default:
            return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0: {
            self.cardExpiryMonth = row + 1;
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar/*NSCalendarIdentifierGregorian*/];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
            self.cardExpiryYear = [components year] + [pickerView selectedRowInComponent:1];
            [self showCardExpiry];
            break;
        }
        case 1: {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar/*NSCalendarIdentifierGregorian*/];
            NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
            self.cardExpiryYear = [components year] + row;
            self.cardExpiryMonth = [pickerView selectedRowInComponent:0] + 1;
            [self showCardExpiry];
            break;
        }
        default:
            break;
    }
    [self validate];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = nil;
    if (textField == self.tfCardNumber)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    if (textField == self.tfCardHolder)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    if (textField == self.tfCardExpiry)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    }
    if (textField == self.tfCardName)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    }
    [self.tblAddCard.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:[string capitalizedString]];
    UITextRange *prevTextRange = [textField selectedTextRange];
    NSUInteger offset = [string isEqualToString:@""] ? -1 : range.length + 1;

    /*Переход назад*/
    if ([string length] == 0)
    {
        if (textField == self.tfCardNumber)
        {
            self.tfCardNumber.text = str;
            self.cardNumber = str;
        }
        if (textField == self.tfCardHolder)
        {
            self.tfCardHolder.text = str;
            self.cardHolder = str;
        }
        if (textField == self.tfCardExpiry)
        {
        }
        if (textField == self.tfCardName)
        {
            self.tfCardName.text = str;
            self.cardName = str;
        }
    }
    else
    {
        if (textField == self.tfCardNumber)
        {
            self.tfCardNumber.text = str;
            self.cardNumber = str;
        }
        if (textField == self.tfCardHolder)
        {
            self.tfCardHolder.text = str;
            self.cardHolder = str;
        }
        if (textField == self.tfCardExpiry)
        {
        }
        if (textField == self.tfCardName)
        {
            self.tfCardName.text = str;
            self.cardName = str;
        }
    }
    
    UITextPosition *cursorPosition = [textField positionFromPosition:prevTextRange.start offset:offset];
    [textField setSelectedTextRange:[textField textRangeFromPosition:cursorPosition toPosition:cursorPosition]];
    [self validate];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark CardAuhtorizeViewControllerDelegate

- (void)finishAuthorizeAction:(UIViewController *)controller
{
    [self.delegate addCardFinished:self withResult:YES];
}

@end
