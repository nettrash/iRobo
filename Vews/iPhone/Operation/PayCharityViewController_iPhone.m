//
//  PayCharityViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 15.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "PayCharityViewController_iPhone.h"
#import "AppDelegate.h"
#import "EnterCVCViewController_iPhone.h"
#import "CardsViewController_iPhone.h"
#import "UIViewController+KeyboardExtensions.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "OperationStateViewController_iPhone.h"

@interface PayCharityViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblCharity;
@property (nonatomic, retain) UITextField *tfPayerLastName;
@property (nonatomic, retain) UITextField *tfPayerFirstName;
@property (nonatomic, retain) UITextField *tfPayerSecondName;
@property (nonatomic, retain) UITextField *tfPayerAddress;
@property (nonatomic, retain) UITextField *tfAdvSumma;
@property (nonatomic, retain) EnterCVCViewController_iPhone *cvcView;
@property (nonatomic, retain) UIButton *doneButton;

@end

@implementation PayCharityViewController_iPhone

@synthesize delegate = _delegate;
@synthesize tfPayerLastName = _tfPayerLastName;
@synthesize tfPayerFirstName = _tfPayerFirstName;
@synthesize tfPayerSecondName = _tfPayerSecondName;
@synthesize tfPayerAddress = _tfPayerAddress;
@synthesize tfAdvSumma = _tfAdvSumma;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withCharity:(svcCharity *)charity
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _charity = charity;
        _card = nil;
        _comissionViewController = nil;
        _summa = _charity.charity_DefaultSum;
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.navigationItem.title = NSLocalizedString(@"PayCharity_Title", @"PayCharity_Title");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PayButton_Title", @"PayButton_Title") style:UIBarButtonItemStyleDone target:self action:@selector(chooseCard:)];
        self.tfPayerLastName = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfPayerLastName.adjustsFontSizeToFitWidth = YES;
        self.tfPayerLastName.textColor = [UIColor darkGrayColor];
        self.tfPayerLastName.placeholder = NSLocalizedString(@"Payer_LastName", @"Payer_LastName");
        self.tfPayerLastName.keyboardType = UIKeyboardTypeDefault;
        self.tfPayerLastName.delegate = self;
        self.tfPayerLastName.text = app.userProfile.lastName;
        
        self.tfPayerFirstName = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfPayerFirstName.adjustsFontSizeToFitWidth = YES;
        self.tfPayerFirstName.textColor = [UIColor darkGrayColor];
        self.tfPayerFirstName.placeholder = NSLocalizedString(@"Payer_FirstName", @"Payer_FirstName");
        self.tfPayerFirstName.keyboardType = UIKeyboardTypeDefault;
        self.tfPayerFirstName.delegate = self;
        self.tfPayerFirstName.text = app.userProfile.firstName;
        
        self.tfPayerSecondName = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfPayerSecondName.adjustsFontSizeToFitWidth = YES;
        self.tfPayerSecondName.textColor = [UIColor darkGrayColor];
        self.tfPayerSecondName.placeholder = NSLocalizedString(@"Payer_SecondName", @"Payer_SecondName");
        self.tfPayerSecondName.keyboardType = UIKeyboardTypeDefault;
        self.tfPayerSecondName.delegate = self;
        self.tfPayerSecondName.text = app.userProfile.secondName;
        
        self.tfPayerAddress = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfPayerAddress.adjustsFontSizeToFitWidth = YES;
        self.tfPayerAddress.textColor = [UIColor darkGrayColor];
        self.tfPayerAddress.placeholder = NSLocalizedString(@"Payer_Address", @"Payer_Address");
        self.tfPayerAddress.keyboardType = UIKeyboardTypeDefault;
        self.tfPayerAddress.delegate = self;
        self.tfPayerAddress.text = app.userProfile.address;
        
        self.tfAdvSumma = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 30)];
        self.tfAdvSumma.adjustsFontSizeToFitWidth = YES;
        self.tfAdvSumma.textColor = [UIColor darkGrayColor];
        self.tfAdvSumma.placeholder = NSLocalizedString(@"Adv_Summa", @"Adv_Summa");;
        self.tfAdvSumma.keyboardType = UIKeyboardTypeDecimalPad;
        self.tfAdvSumma.delegate = self;
        self.tfAdvSumma.text = [NSString stringWithFormat:@"%.2f", [_charity.charity_DefaultSum doubleValue]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _needToShowDoneButton = NO;
    
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

    [self validate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tblCharity.view removeFromSuperview];
    
    self.tblCharity.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20);
    if (_keyboardIsShowing) {
        CGRect frame = self.tblCharity.view.frame;
        frame.size.height -= [_keyboardHeight floatValue];
        self.tblCharity.view.frame = frame;
	}
    
    [self.view addSubview:self.tblCharity.view];
    
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
    
	CGRect frame = self.tblCharity.view.frame;
	frame.size.height -= [_keyboardHeight floatValue];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	
	self.tblCharity.view.frame = frame;
	
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
        CGRect frame = self.tblCharity.view.frame;
        frame.size.height += [_keyboardHeight floatValue];
		
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
		
        self.tblCharity.view.frame = frame;
		
        [UIView commitAnimations];
	}
}

- (void)addDoneButtonToNumberPadKeyboard
{
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for (int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            if([[keyboard description] hasPrefix:@"<UIInputSetContainerView"] == YES) {
                NSArray *a = [(UIView *)keyboard subviews];
                [(UIView *)[a objectAtIndex:0] addSubview:self.doneButton];
                [(UIView *)[a objectAtIndex:0] bringSubviewToFront:self.doneButton];
            }
        } else {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
                if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES) {
                    [keyboard addSubview:self.doneButton];
                    [keyboard bringSubviewToFront:self.doneButton];
                }
            } else {
                if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                    [keyboard addSubview:self.doneButton];
            }
        }
    }
}

- (void)removeDoneButtonFromNumberPadKeyboard
{
    if (!_keyboardIsShowing) return;
    
    [self.doneButton removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)validate
{
    _summa = [NSDecimalNumber decimalNumberWithString:[self.tfAdvSumma.text stringByReplacingOccurrencesOfString:@"," withString:@"."]];
    BOOL bValid = _charity && _charity != nil && _charity.charity_Active && [[[NSDate date] earlierDate:_charity.charity_StartDate] isEqualToDate:_charity.charity_StartDate] && (!_charity.charity_EndDate || _charity.charity_EndDate == nil || [[[NSDate date] laterDate:_charity.charity_EndDate] isEqualToDate:_charity.charity_EndDate]) && ([_summa compare:_charity.charity_DefaultSum] == NSOrderedDescending || [_summa compare:_charity.charity_DefaultSum] == NSOrderedSame);
    
    self.navigationItem.rightBarButtonItem.enabled = bValid;
}

- (void)chooseCard:(id)sender
{
    [self hideKeyboard];
    _summa = [NSDecimalNumber decimalNumberWithString:[self.tfAdvSumma.text stringByReplacingOccurrencesOfString:@"," withString:@"."]];
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
    _comissionViewController = [[ComissionViewController_iPhone alloc] initWithNibName:@"ComissionViewController_iPhone" bundle:nil currency:@"OceanBankPayToAnyReqR" OutSumma:_summa cardId:[_card card_Id]];
    _comissionViewController.delegate = self;
    [_comissionViewController performSelector:@selector(addToViewController:) withObject:self.navigationController.topViewController afterDelay:.1];
}

- (void)showTranferAddOn
{
    [self hideKeyboard];
    _comissionViewController = [[ComissionViewController_iPhone alloc] initWithNibName:@"ComissionViewController_iPhone" bundle:nil currency:@"OceanBankPayToAnyReqR" OutSumma:_summa cardId:[_card card_Id] andBackground:@"TransferAddOn.png"];
    _comissionViewController.delegate = self;
    [_comissionViewController performSelector:@selector(addToViewController:) withObject:self.navigationController.topViewController afterDelay:.1];
}


- (void)startOperation:(NSString *)cvc
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"StartOperation_WaitMessage", @"StartOperation_WaitMessage")];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;

    [svc PayCharity:self action:@selector(startOperationHandler:) UNIQUE:[app.userProfile uid] charityId:_charity.charity_Id cardId:_card.card_Id summa:_summa CVC:_cvc PayerFIO:[NSString stringWithFormat:@"%@ %@ %@", self.tfPayerLastName.text, self.tfPayerFirstName.text, self.tfPayerSecondName.text] PayerAddress:self.tfPayerAddress.text];
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

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 6;
        case 1:
            return 4;
        case 2:
            return 6;
        case 3:
            return 2;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"MoneyTransfer_Section_Charity", @"MoneyTransfer_Section_Charity");
        case 1:
            return NSLocalizedString(@"MoneyTransfer_Section_Payeer", @"MoneyTransfer_Section_Payeer");
        case 2:
            return NSLocalizedString(@"MoneyTransfer_Section_Receiver", @"MoneyTransfer_Section_Receiver");
        case 3:
            return NSLocalizedString(@"MoneyTransfer_Section_Summa", @"MoneyTransfer_Section_Summa");
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MTCharityItemCell"];
            BOOL dequeued = YES;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MTCharityItemCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                dequeued = NO;
            }
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = _charity.charity_Name;
                    cell.detailTextLabel.text = NSLocalizedString(@"CHARITY_Name", @"CHARITY_Name");
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                case 1: {
                    cell.textLabel.text = _charity.charity_Description;
                    cell.detailTextLabel.text = NSLocalizedString(@"CHARITY_Description", @"CHARITY_Description");
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                case 2: {
                    if (_charity.charity_URL && _charity.charity_URL != nil && ![_charity.charity_URL isEqualToString:@""])
                    {
                        cell.textLabel.text = NSLocalizedString(@"LinkToUrl", @"LinkToUrl");//_charity.charity_URL;
                        cell.detailTextLabel.text = NSLocalizedString(@"CHARITY_Link", @"CHARITY_Link");
                        cell.accessoryType = UITableViewCellAccessoryDetailButton;
                    }
                    else
                    {
                        cell.textLabel.text = NSLocalizedString(@"CHARITY_NoLinkToUrl", @"CHARITY_NoLinkToUrl");//_charity.charity_URL;
                        cell.detailTextLabel.text = NSLocalizedString(@"CHARITY_Link", @"CHARITY_Link");
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                }
                case 3: {
                    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:_charity.charity_StartDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
                    cell.detailTextLabel.text = NSLocalizedString(@"CHARITY_StartDate", @"CHARITY_StartDate");
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                case 4: {
                    if (_charity.charity_EndDate && _charity.charity_EndDate != nil)
                        cell.textLabel.text = [NSDateFormatter localizedStringFromDate:_charity.charity_EndDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
                    else
                        cell.textLabel.text = NSLocalizedString(@"CHARITY_NoEndDate", @"CHARITY_NoEndDate");
                    cell.detailTextLabel.text = NSLocalizedString(@"CHARITY_EndDate", @"CHARITY_EndDate");
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                case 5: {
                    cell.textLabel.text = _charity.charity_Active ? NSLocalizedString(@"CHARITY_Active", @"CHARITY_Active") : NSLocalizedString(@"CHARITY_InActive", @"CHARITY_InActive");
                    cell.detailTextLabel.text = NSLocalizedString(@"CHARITY_ActiveLabel", @"CHARITY_ActiveLabel");
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                default:
                    break;
            }
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
            break;
        }
        case 1: {
            cell = nil;//[tableView dequeueReusableCellWithIdentifier:@"MTPayerItemCell"];
            BOOL dequeued = YES;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MTPayerItemCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                dequeued = NO;
            }
            switch (indexPath.row) {
                case 0: {
                    [cell addSubview:self.tfPayerLastName];
                    break;
                }
                case 1: {
                    [cell addSubview:self.tfPayerFirstName];
                    break;
                }
                case 2: {
                    [cell addSubview:self.tfPayerSecondName];
                    break;
                }
                case 3: {
                    [cell addSubview:self.tfPayerAddress];
                    break;
                }
                default:
                    break;
            }
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
            break;
        }
        case 2: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MTReceiverItemCell"];
            BOOL dequeued = YES;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MTReceiverItemCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                dequeued = NO;
            }
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = _charity.charity_RS;
                    cell.detailTextLabel.text = NSLocalizedString(@"BANK_ReceiverAccount", @"BANK_ReceiverAccount");
                    break;
                }
                case 1: {
                    cell.textLabel.text = _charity.charity_Person;
                    cell.detailTextLabel.text = NSLocalizedString(@"BANK_ReceiverName", @"BANK_ReceiverName");
                    break;
                }
                case 2: {
                    cell.textLabel.text = _charity.charity_BIK;
                    cell.detailTextLabel.text = NSLocalizedString(@"BANK_ReceiverBIK", @"BANK_ReceiverBIK");
                    break;
                }
                case 3: {
                    cell.textLabel.text = _charity.charity_BANK;
                    cell.detailTextLabel.text = NSLocalizedString(@"BANK_ReceiverBankName", @"BANK_ReceiverBankName");
                    break;
                }
                case 4: {
                    cell.textLabel.text = _charity.charity_INN;
                    cell.detailTextLabel.text = NSLocalizedString(@"BANK_ReceiverINN", @"BANK_ReceiverINN");
                    break;
                }
                case 5: {
                    cell.textLabel.text = _charity.charity_KPP;
                    cell.detailTextLabel.text = NSLocalizedString(@"BANK_ReceiverKPP", @"BANK_ReceiverKPP");
                    break;
                }
                default:
                    break;
            }
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
            break;
        }
        case 3: {
            cell = nil;//[tableView dequeueReusableCellWithIdentifier:@"MTAdvItemCell"];
            BOOL dequeued = YES;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MTAdvItemCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                dequeued = NO;
            }
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = _charity.charity_Designation;
                    cell.detailTextLabel.text = NSLocalizedString(@"BANK_PurposeOfPayment", @"BANK_PurposeOfPayment");
                    break;
                }
                case 1: {
                    [cell addSubview:self.tfAdvSumma];
                    break;
                }
                default:
                    break;
            }
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
            break;
        }
        default: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MTItemCell"];
            BOOL dequeued = YES;
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MTItemCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                dequeued = NO;
            }
            
            cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:8];
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
            break;
        }
    }
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2 && _charity.charity_URL && _charity.charity_URL != nil && ![_charity.charity_URL isEqualToString:@""])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_charity.charity_URL]];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = nil;
    if (textField == self.tfPayerLastName)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    if (textField == self.tfPayerFirstName)
    {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    }
    if (textField == self.tfPayerSecondName)
    {
        indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    }
    if (textField == self.tfPayerAddress)
    {
        indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
    }
    if (textField == self.tfAdvSumma)
    {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:3];
    }
    [self.tblCharity.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextRange *prevTextRange = [textField selectedTextRange];
    NSUInteger offset = [string isEqualToString:@""] ? -1 : range.length + 1;
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UITextPosition *cursorPosition = [textField positionFromPosition:prevTextRange.start offset:offset];
    [textField setSelectedTextRange:[textField textRangeFromPosition:cursorPosition toPosition:cursorPosition]];
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
            [self showTranferAddOn];
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

@end
