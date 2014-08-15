//
//  Card2CardTransferViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 29.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "Card2CardTransferViewController_iPhone.h"
#import "EnterCVCViewController_iPhone.h"
#import "svcCard.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"
#import "NSNumber+Currency.h"
#import "NSString+RegEx.h"
#import "OperationStateViewController_iPhone.h"
#import "AddCardViewController_iPhone.h"

@interface Card2CardTransferViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblPrms;
@property (nonatomic, retain) IBOutlet UITextField *tfFromCard;
@property (nonatomic, retain) IBOutlet UITextField *tfToCard;
@property (nonatomic, retain) IBOutlet UITextField *tfSumma;
@property (nonatomic, retain) svcCard *fromCard;
@property (nonatomic, retain) NSString *toCardNumber;
@property (nonatomic, retain) NSNumber *summa;
@property (nonatomic, retain) UIPickerView *pvCards;
@property (nonatomic, retain) EnterCVCViewController_iPhone *cvcView;

@end

@implementation Card2CardTransferViewController_iPhone

@synthesize delegate = _delegate;
@synthesize tblPrms = _tblPrms;
@synthesize tfFromCard = _tfFromCard;
@synthesize tfToCard = _tfToCard;
@synthesize tfSumma = _tfSumma;
@synthesize fromCard = _fromCard;
@synthesize toCardNumber = _toCardNumber;
@synthesize summa = _summa;
@synthesize pvCards = _pvCards;
@synthesize cvcView = _cvcView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _cards = nil;
        self.summa = [NSNumber numberWithInt:1000];
        self.toCardNumber = @"";
        self.navigationItem.title = NSLocalizedString(@"Card2CardTransfer_Title", @"Card2CardTransfer_Title");

        self.tfFromCard = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfFromCard.adjustsFontSizeToFitWidth = YES;
        self.tfFromCard.textColor = [UIColor darkGrayColor];
        self.tfFromCard.keyboardType = UIKeyboardTypeNumberPad;
        self.pvCards = [[UIPickerView alloc] init];
        self.pvCards.dataSource = self;
        self.pvCards.delegate = self;
        [self.tfFromCard setInputView:self.pvCards];
        self.tfFromCard.delegate = self;
        
        self.tfToCard = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfToCard.adjustsFontSizeToFitWidth = YES;
        self.tfToCard.textColor = [UIColor darkGrayColor];
        self.tfToCard.keyboardType = UIKeyboardTypeNumberPad;
        self.tfToCard.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.tfToCard.delegate = self;
        
        self.tfSumma = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 180, 30)];
        self.tfSumma.adjustsFontSizeToFitWidth = YES;
        self.tfSumma.textColor = [UIColor darkGrayColor];
        self.tfSumma.keyboardType = UIKeyboardTypeNumberPad;
        self.tfSumma.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.tfSumma.delegate = self;
        self.tfSumma.text = @"1000";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withToCardNumber:(NSString *)toCardNumber
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _cards = nil;
        self.summa = [NSNumber numberWithInt:1000];
        self.toCardNumber = @"";
        self.navigationItem.title = NSLocalizedString(@"Card2CardTransfer_Title", @"Card2CardTransfer_Title");
        
        self.tfFromCard = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfFromCard.adjustsFontSizeToFitWidth = YES;
        self.tfFromCard.textColor = [UIColor darkGrayColor];
        self.tfFromCard.keyboardType = UIKeyboardTypeNumberPad;
        self.pvCards = [[UIPickerView alloc] init];
        self.pvCards.dataSource = self;
        self.pvCards.delegate = self;
        [self.tfFromCard setInputView:self.pvCards];
        self.tfFromCard.delegate = self;
        
        self.tfToCard = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfToCard.adjustsFontSizeToFitWidth = YES;
        self.tfToCard.textColor = [UIColor darkGrayColor];
        self.tfToCard.keyboardType = UIKeyboardTypeNumberPad;
        self.tfToCard.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.tfToCard.delegate = self;
        self.toCardNumber = [NSString stringWithString:toCardNumber];
        self.tfToCard.text = self.toCardNumber;
        
        self.tfSumma = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 180, 30)];
        self.tfSumma.adjustsFontSizeToFitWidth = YES;
        self.tfSumma.textColor = [UIColor darkGrayColor];
        self.tfSumma.keyboardType = UIKeyboardTypeNumberPad;
        self.tfSumma.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.tfSumma.delegate = self;
        self.tfSumma.text = @"1000";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cvcView = [[EnterCVCViewController_iPhone alloc] initWithNibName:@"EnterCVCViewController_iPhone" bundle:nil];
    self.cvcView.delegate = self;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PayButton_Title", @"PayButton_Title") style:UIBarButtonItemStyleDone target:self action:@selector(btnDone_Click:)];
    
    [self validate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tblPrms.view removeFromSuperview];
    
    self.tblPrms.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20);
    if (_keyboardIsShowing) {
        CGRect frame = self.tblPrms.view.frame;
        frame.size.height -= [_keyboardHeight floatValue];
        self.tblPrms.view.frame = frame;
	}
    
    [self.view addSubview:self.tblPrms.view];

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

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"Card2CardTransfer_WaitMessage", @"Card2CardTransfer_WaitMessage")];
    [self performSelector:@selector(getCards) withObject:nil afterDelay:.1];
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
	
	CGRect frame = self.tblPrms.view.frame;
	frame.size.height -= [_keyboardHeight floatValue];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	
	self.tblPrms.view.frame = frame;
	
	[UIView commitAnimations];
}

- (void)keyboardDidShow : (NSNotification *) note
{
}

- (void)keyboardWillHide : (NSNotification *) note
{
    if (_keyboardIsShowing) {
        _keyboardIsShowing = NO;
        CGRect frame = self.tblPrms.view.frame;
        frame.size.height += [_keyboardHeight floatValue];
		
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
		
        self.tblPrms.view.frame = frame;
		
        [UIView commitAnimations];
	}
}

- (void)initToCardNumber:(NSString *)toCardNumber
{
    self.toCardNumber = [NSString stringWithString:toCardNumber];
    self.tfToCard.text = self.toCardNumber;
}

- (void)getCards
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetCards:self action:@selector(getCardsHandler:) UNIQUE:[app.userProfile uid] Hash:@"" NotIncludeRemoved:YES NotIncludeNotAuthorized:YES];
}

- (void)getCardsHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.cards && resp.cards != nil && [resp.cards count] > 0)
            {
                _cards = [NSArray arrayWithArray:resp.cards];
                self.fromCard = (svcCard *)[_cards objectAtIndex:0];
                [self refreshFromCardText];
                [self.tfFromCard becomeFirstResponder];
                return;
            }
            else
            {
                //Нет карт, перенаправляем на страницу добавления карты
                //Одновременно показывая сообщение о том что карт нет и надо добавить
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoCard_NeedToAddCard_Title",@"NoCard_NeedToAddCard_Title") message:NSLocalizedString(@"NoCard_NeedToAddCard_Message",@"NoCard_NeedToAddCard_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue",@"Button_Continue") otherButtonTitles:nil];
                [alert show];
                [self gotoAddCard];
            }
        }
    }
    [self.delegate finishPay:self];
}

- (void)gotoAddCard
{
    AddCardViewController_iPhone *addCardViewController = [[AddCardViewController_iPhone alloc] initWithNibName:@"AddCardViewController_iPhone" bundle:nil];
    addCardViewController.delegate = self;
    [self.navigationController pushViewController:addCardViewController animated:YES];
}

- (void)refreshFromCardText
{
    if (!self.fromCard || self.fromCard == nil)
    {
        self.tfFromCard.text = @"";
        return;
    }
    self.tfFromCard.text = [self getCardText:self.fromCard];
}

- (NSString *)getCardText:(svcCard *)crd
{
    if (crd.card_IsOCEAN)
    {
        return [NSString stringWithFormat:@"%@ (%@)", crd.card_Number, [crd.card_Balance numberWithCurrencyShort]];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ (%@)", crd.card_Number, crd.card_Name];
    }
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
    BOOL bValidSumma = [self.tfSumma.text intValue] > 0 && [self.tfSumma.text intValue] < 75001;
    
    if (!bValidSumma) {
        UITableViewCell *cell = [self.tblPrms.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        cell.detailTextLabel.text = @"ERROR";
    }
    
    BOOL bValidToCard = self.toCardNumber ? [self.toCardNumber length] == 16 && [self.toCardNumber checkFormat:@"^\\d{16}$"] && [self isValidCC:self.toCardNumber] : NO;
    
    if (bValidSumma && bValidToCard)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return bValidSumma && bValidToCard;
}

- (IBAction)btnDone_Click:(id)sender
{
    [self.tfFromCard resignFirstResponder];
    [self.tfToCard resignFirstResponder];
    [self.tfSumma resignFirstResponder];
    [self.navigationController.topViewController.navigationItem setHidesBackButton:YES animated:YES];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationController.topViewController.navigationItem.rightBarButtonItem.enabled = NO;
    [self.cvcView applyCard:self.fromCard.card_Id];
    [self.cvcView performSelector:@selector(addToViewController:) withObject:self afterDelay:.1];
}

- (void)updateCommission
{
    int summ = [self.summa intValue];
    double comission = summ * 0.0199f;
    if (comission < 50) comission = 50;
    NSNumber *nComission = [NSNumber numberWithDouble:comission];
    [self.tblPrms.tableView beginUpdates];
    UITableViewCell *cell = [self.tblPrms.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"c2ct_comission", @""), [nComission numberWithCurrency]];
    [self.tblPrms.tableView endUpdates];
}

- (void)startOperation:(NSString *)cvc
{
    int fromCardId = 0;
    int toCardId = 0;
    NSString *toCardNumber = @"";
    fromCardId = self.fromCard.card_Id;
    toCardNumber = self.toCardNumber;

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"StartOperation_WaitMessage", @"StartOperation_WaitMessage")];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc Card2CardTransfer:self action:@selector(startOperationHandler:) UNIQUE:[app.userProfile uid] fromCardId:fromCardId toCardId:toCardId toCardNumber:toCardNumber summ:[NSDecimalNumber decimalNumberWithString:self.tfSumma.text] fromCardCVC:cvc];
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
            OperationStateViewController_iPhone *ov = [[OperationStateViewController_iPhone alloc] initWithNibName:@"OperationStateViewController_iPhone" bundle:nil OpKey:resp.OpKey];
            ov.delegate = self;
            [self.navigationController pushViewController:ov animated:YES];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"Card2CardTransfer_FromCard", @"Card2CardTransfer_FromCard");
        case 1:
            return NSLocalizedString(@"Card2CardTransfer_ToCard", @"Card2CardTransfer_ToCard");
        case 2:
            return NSLocalizedString(@"Card2CardTransfer_Summa", @"Card2CardTransfer_Summa");
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:@"С2СItemCell"];
    BOOL dequeued = YES;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"С2СItemCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        dequeued = NO;
    }
    
    switch (indexPath.section) {
        case 0: {
            [self refreshFromCardText];
            if (!dequeued)
            {
                [cell addSubview:self.tfFromCard];
            }
            break;
        }
        case 1: {
            self.tfToCard.text = self.toCardNumber;
            if (!dequeued)
                [cell addSubview:self.tfToCard];
            break;
        }
        case 2: {
            self.tfSumma.text = [self.summa stringValue];
            int summ = [self.summa intValue];
            double comission = summ * 0.0199f;
            if (comission < 50) comission = 50;
            NSNumber *nComission = [NSNumber numberWithDouble:comission];
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"c2ct_comission", @""), [nComission numberWithCurrency]];
            if (!dequeued)
                [cell addSubview:self.tfSumma];
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

#pragma mark EnterCVCDelegate

-(void)finishEnterCVC:(UIViewController *)controller cvcEntered:(BOOL)cvcEntered cvcValue:(NSString*)cvcValue
{
    [self.navigationController.topViewController.navigationItem setHidesBackButton:NO animated:YES];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationController.topViewController.navigationItem.rightBarButtonItem.enabled = YES;
    if (cvcEntered)
    {
        [(EnterCVCViewController_iPhone *)controller removeFromViewController];
        [self performSelector:@selector(startOperation:) withObject:cvcValue afterDelay:.1];
    }
    else
    {
        [self.delegate finishPay:self];
    }
}

- (void)cancelEnterCVC:(UIViewController *)controller
{
    [self.navigationController.topViewController.navigationItem setHidesBackButton:NO animated:YES];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationController.topViewController.navigationItem.rightBarButtonItem.enabled = YES;
    [self.delegate finishPay:self];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_cards count];
}

#pragma mark UIPickerViewDelegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    svcCard *c = (svcCard *)[_cards objectAtIndex:row];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[self getCardText:c]];
    UIFont *f = [UIFont systemFontOfSize:8];
    [as addAttribute:NSFontAttributeName value:(id)f range:NSMakeRange(0, [as length] - 1)];
    return as;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.fromCard = (svcCard *)[_cards objectAtIndex:row];
    [self refreshFromCardText];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = nil;
    if (textField == self.tfFromCard)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    if (textField == self.tfToCard)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    if (textField == self.tfSumma)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    }
    [self.tblPrms.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    if (textField == self.tfFromCard)
        return NO;
    else
    {
        if (textField == self.tfSumma)
        {
            self.tfSumma.text = str;
            self.summa = [NSNumber numberWithInt:[str intValue]];
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

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
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

#pragma mark AddCardViewControllerDelegate

- (void)addCardFinished:(UIViewController *)controller withResult:(BOOL)result
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"Card2CardTransfer_WaitMessage", @"Card2CardTransfer_WaitMessage")];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self performSelector:@selector(getCards) withObject:nil afterDelay:.1];
}


@end
