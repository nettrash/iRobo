//
//  MainViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 08.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "MainViewController_iPhone.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "svcCheck.h"
#import "NSNumber+Currency.h"
#import "PayPhoneViewController_iPhone.h"
#import "Card2CardTransferViewController_iPhone.h"
#import "MoneyTransferViewController_iPhone.h"
#import "PayCheckViewController_iPhone.h"
#import "svcTopCurrency.h"
#import "PayViewController_iPhone.h"
#import "SearchCatalogViewController_iPhone.h"
#import "ScanViewController_iPhone.h"

@interface MainViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblPayments;

@end

@implementation MainViewController_iPhone

@synthesize tblPayments = _tblPayments;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstInitialized = NO;
        _checksRefreshing = NO;
        _topCatalogRefreshing = NO;
        _checks = nil;
        self.navigationItem.title = NSLocalizedString(@"MainTitle", @"MainTitle");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scan:)];
        SWRevealViewController *revealViewController = [self revealViewController];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    self.tblPayments.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 16, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 16);
    [self.view addSubview:self.tblPayments.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblPayments setRefreshControl:refreshControl];
    if (!_firstInitialized)
        [self performSelector:@selector(refresh:) withObject:nil afterDelay:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)scan:(id)sender
{
    ScanViewController_iPhone *v = [[ScanViewController_iPhone alloc] initWithNibName:@"ScanViewController_iPhone" bundle:nil delegate:self];
    [self presentViewController:v animated:YES completion:nil];
}

- (void)refresh:(id)sender
{
    _firstInitialized = YES;
    [self getChecks:nil];
    [self getTopCurrencyList:nil];
}

- (void)getChecks:(id)sender
{
    _checksRefreshing = YES;
    if (!self.tblPayments.refreshControl.isRefreshing)
    {
        [self.tblPayments.refreshControl beginRefreshing];
    }
    [self.tblPayments.tableView reloadData];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetChecks:self action:@selector(getChecksHandler:) UNIQUE:[app.userProfile uid]];
}

- (void)getChecksHandler:(id)response
{
    _checksRefreshing = NO;
    if (!_checksRefreshing && !_topCatalogRefreshing)
        [self.tblPayments.refreshControl endRefreshing];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.checks && resp.checks != nil && [resp.checks count] > 0)
            {
                _checks = [NSArray arrayWithArray:resp.checks];
                BOOL allNew = YES;
                for (svcCheck *c in _checks)
                {
                    if (![[c.State uppercaseString] isEqualToString:@"NEW"])
                    {
                        allNew = NO;
                    }
                }
                if (!allNew)
                {
                    [self performSelector:@selector(getChecks:) withObject:nil afterDelay:5];
                }
            }
            else
            {
                _checks = nil;
            }
        }
        else
        {
            _checks = nil;
        }
    }
    else
    {
        _checks = nil;
    }
    [self.tblPayments.tableView reloadData];
}

- (void)getTopCurrencyList:(id)sender
{
    _topCatalogRefreshing = YES;
    if (!self.tblPayments.refreshControl.isRefreshing)
    {
        [self.tblPayments.refreshControl beginRefreshing];
    }
    [self.tblPayments.tableView reloadData];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetTopCatalog:self action:@selector(getTopCurrencyListHandler:) UNIQUE:[app.userProfile uid]];
}

- (void)getTopCurrencyListHandler:(id)response
{
    _topCatalogRefreshing = NO;
    if (!_checksRefreshing && !_topCatalogRefreshing)
        [self.tblPayments.refreshControl endRefreshing];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            _topCatalog = resp.topcatalog;
        }
    }
    [self.tblPayments.tableView reloadData];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"MainTable_Section_Checks", @"MainTable_Section_Checks");
        case 1:
            return NSLocalizedString(@"MainTable_Section_Helpers", @"MainTable_Section_Helpers");
        case 2:
            return NSLocalizedString(@"MainTable_Section_AutoFavorites", @"MainTable_Section_AutoFavorites");
        case 3:
            return NSLocalizedString(@"MainTable_Section_Other", @"MainTable_Section_Other");
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: {
            if (_checksRefreshing) return 1;
            if (_checks && _checks != nil && [_checks count] > 0)
                return [_checks count];
            else
                return 1;
        }
        case 1: {
            return 3;
        }
        case 2: {
            if (_topCatalog && _topCatalog != nil && [_topCatalog count] > 0)
                if (_topCatalogRefreshing)
                    return 1;
                else
                    return [_topCatalog count];
            else
                return 1;
        }
        case 3: {
            if (![MFMailComposeViewController canSendMail])
                return 1;
            return 2;
        }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MainCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
        case 0: {
            if (_checksRefreshing)
            {
                cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Checks_RefreshCheck_Title", @"MainTable_Section_Checks_RefreshCheck_Title");
                cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Checks_RefreshCheck_Details", @"MainTable_Section_Checks_RefreshCheck_Details");
                UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                ai.hidesWhenStopped = NO;
                [ai startAnimating];
                cell.accessoryView = ai;
                cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];
            }
            else
            {
                if (_checks && _checks != nil && [_checks count] > 0)
                {
                    svcCheck *chk = (svcCheck *)[_checks objectAtIndex:indexPath.row];
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"№%@ %@", chk.MerchantOrder, chk.MerchantName];
                    cell.detailTextLabel.text = [chk.Summa numberWithCurrency];
                    cell.accessoryView = nil;
                    if (![[chk.State uppercaseString] isEqualToString:@"NEW"]) {
                        UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        ai.hidesWhenStopped = YES;
                        [ai startAnimating];
                        cell.accessoryView = ai;
                    }
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.imageView.image = [UIImage imageNamed:@"MainCheckIcon.png"];
                }
                else
                {
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Checks_NoCheck_Title", @"MainTable_Section_Checks_NoCheck_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Checks_NoCheck_Details", @"MainTable_Section_Checks_NoCheck_Details");
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_Phone_Title", @"MainTable_Section_Helpers_Phone_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_Phone_Details", @"MainTable_Section_Helpers_Phone_Details");
                    cell.imageView.image = [UIImage imageNamed:@"MainPhoneIcon.png"];
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 1: {
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_CardMoneyTransfer_Title", @"MainTable_Section_Helpers_CardMoneyTransfer_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_CardMoneyTransfer_Details", @"MainTable_Section_Helpers_CardMoneyTransfer_Details");
                    cell.imageView.image = [UIImage imageNamed:@"MainCard2CardIcon.png"];
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 2: {
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_MoneyTransfer_Title", @"MainTable_Section_Helpers_MoneyTransfer_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_MoneyTransfer_Details", @"MainTable_Section_Helpers_MoneyTransfer_Details");
                    cell.imageView.image = [UIImage imageNamed:@"MainTransferIcon.png"];
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 3: {
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2: {
            if (_topCatalog && _topCatalog != nil && [_topCatalog count] > 0)
            {
                if (_topCatalogRefreshing)
                {
                    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    ai.hidesWhenStopped = YES;
                    [ai startAnimating];
                    cell.accessoryView = ai;
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Top_RefreshTop_Title", @"MainTable_Section_Top_RefreshTop_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Top_RefreshTop_Details", @"MainTable_Section_Top_RefreshTop_Details");
                    cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];;
                }
                else
                {
                    svcTopCurrency *curr = (svcTopCurrency *)[_topCatalog objectAtIndex:indexPath.row];
                    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", curr.Label]];
                    if (cell.imageView.image == nil)
                        cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];;
                    cell.textLabel.text = [curr.Name uppercaseString];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            else
            {
                if (_topCatalogRefreshing)
                {
                    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    ai.hidesWhenStopped = YES;
                    [ai startAnimating];
                    cell.accessoryView = ai;
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Top_RefreshTop_Title", @"MainTable_Section_Top_RefreshTop_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Top_RefreshTop_Details", @"MainTable_Section_Top_RefreshTop_Details");
                    cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];;
                }
                else
                {
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Top_NoTop_Title", @"MainTable_Section_Top_NoTop_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Top_NoTop_Details", @"MainTable_Section_Top_NoTop_Details");
                    cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];;
                }
            }
            break;
        }
        case 3: {
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Other_CatalogSearch_Title", @"MainTable_Section_Other_CatalogSearch_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Other_CatalogSearch_Details", @"MainTable_Section_Other_CatalogSearch_Details");
                    cell.imageView.image = [UIImage imageNamed:@"CatalogSearchIcon.png"];;
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Other_CatalogAdd_Title", @"MainTable_Section_Other_CatalogAdd_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Other_CatalogAdd_Details", @"MainTable_Section_Other_CatalogAdd_Details");
                    cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];;
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }

    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            if (_checks && _checks != nil && [_checks count] > 0)
            {
                svcCheck *chk = (svcCheck *)[_checks objectAtIndex:indexPath.row];
                PayCheckViewController_iPhone *pp = [[PayCheckViewController_iPhone alloc] initWithNibName:@"PayCheckViewController_iPhone" bundle:nil withCheck:chk];
                pp.delegate = self;
                [self.navigationController pushViewController:pp animated:YES];
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    PayPhoneViewController_iPhone *pp = [[PayPhoneViewController_iPhone alloc] initWithNibName:@"PayPhoneViewController_iPhone" bundle:nil];
                    pp.delegate = self;
                    [self.navigationController pushViewController:pp animated:YES];
                    break;
                }
                case 1: {
                    Card2CardTransferViewController_iPhone *pp = [[Card2CardTransferViewController_iPhone alloc] initWithNibName:@"Card2CardTransferViewController_iPhone" bundle:nil];
                    pp.delegate = self;
                    [self.navigationController pushViewController:pp animated:YES];
                    break;
                }
                case 2: {
                    MoneyTransferViewController_iPhone *pp = [[MoneyTransferViewController_iPhone alloc] initWithNibName:@"MoneyTransferViewController_iPhone" bundle:nil];
                    pp.delegate = self;
                    [self.navigationController pushViewController:pp animated:YES];
                    break;
                }
                case 3: {
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2: {
            svcTopCurrency *curr = (svcTopCurrency *)[_topCatalog objectAtIndex:indexPath.row];
            PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:curr];
            pp.delegate = self;
            [self.navigationController pushViewController:pp animated:YES];
            break;
        }
        case 3: {
            switch (indexPath.row) {
                case 0: {
                    SearchCatalogViewController_iPhone *pp = [[SearchCatalogViewController_iPhone alloc] initWithNibName:@"SearchCatalogViewController_iPhone" bundle:nil];
                    pp.delegate = self;
                    [self.navigationController pushViewController:pp animated:YES];
                    break;
                }
                case 1: {
                    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
                    
                    [mailController setSubject:NSLocalizedString(@"MailSubject_AddToCatalog", @"MailSubject_AddToCatalog")];
                    [mailController setMessageBody:NSLocalizedString(@"MailBody_AddToCatalog", @"MailBody_AddToCatalog") isHTML:YES];
                    [mailController setToRecipients:[NSArray arrayWithObject:@"support@robokassa.ru"]];
                    
                    mailController.mailComposeDelegate = self;
                    
                    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:mailController animated:YES completion:nil];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark PayViewControllerDelegate

- (void)finishPay:(UIViewController *)controller
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self performSelector:@selector(getChecks:) withObject:nil afterDelay:1];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark SearchCatalogDelegate

- (void)searchResult:(UIViewController *)controller withCurrency:(svcTopCurrency *)currency
{
    NSUInteger idx = [_topCatalog indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
        BOOL b = NO;
        if ([[(svcTopCurrency *)obj Label] isEqualToString:[currency Label]])
            b = YES;
        return b;
    }];
    if (idx >= [_topCatalog count])
        [(NSMutableArray *)_topCatalog addObject:currency];
    [self.tblPayments.tableView reloadData];
    PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:currency];
    pp.delegate = self;
    [self.navigationController pushViewController:pp animated:YES];
}

#pragma mark URLProcessing methods

- (void)payCheckById:(int)check_Id
{
    //UNSUPPORTED!!!
}

- (void)payCheckByOpKey:(NSString *)OpKey
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"PayCheckByCommand_WaitMessage", @"PayCheckByCommand_WaitMessage")];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc CreateCheckByOpKey:self action:@selector(createCheckByOpKeyHandler:) UNIQUE:[app.userProfile uid] OpKey:OpKey];
}

- (void)createCheckByOpKeyHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result && resp.checks && resp.checks != nil && [resp.checks count] > 0)
        {
            _checks = resp.checks;
            for (svcCheck *c in resp.checks)
            {
                if (c.checkId == resp.checkId)
                {
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    PayCheckViewController_iPhone *pp = [[PayCheckViewController_iPhone alloc] initWithNibName:@"PayCheckViewController_iPhone" bundle:nil withCheck:c];
                    pp.delegate = self;
                    [self.navigationController pushViewController:pp animated:YES];
                    return;
                }
            }
        }
    }
}

#pragma mark ScanProcessing

- (void)processScanResult:(ZXResult *)result
{
    switch (result.barcodeFormat) {
        case kBarcodeFormatQRCode: {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app performSelector:@selector(applyScanedURL:) withObject:[NSURL URLWithString:result.text] afterDelay:.1];
            break;
        }
        case kBarcodeFormatCode128:
        case kBarcodeFormatEan8: {
            
            if (result.text && result.text != nil && [result.text length] == 28) {
            /*
             ЖКУ - Москва 
             
             Labe QiwiS265
             Name ЖКУ Москва
             P5929_account[0] Код абонента
             P5929_account[1] ММГГ
             
             OutPossibleValues Суммы через ;
             
             Пример 2840914162091303581140367153
             Код абонента 2840914162 (с 0 по 9 символ)
             Период ММГГ 0913 (с 10 по 13)
             Сумма без страховки 0358114 3581.14
             Сумма со страховкой 0367153 3671.53
             */
                svcTopCurrency *c = [svcTopCurrency alloc];
                c.Label = @"QiwiS265";
                c.Name = @"ЖКУ Москва";
                c.Parameters = [NSString stringWithFormat:@"P5929_account[0]:%@;P5929_account[1]:%@", [result.text substringWithRange:NSMakeRange(0, 10)], [result.text substringWithRange:NSMakeRange(10, 4)]];
                c.OutPossibleValues = [NSString stringWithFormat:@"%@.%@;%@.%@", [result.text substringWithRange:NSMakeRange(14, 5)], [result.text substringWithRange:NSMakeRange(19, 2)], [result.text substringWithRange:NSMakeRange(21, 5)], [result.text substringWithRange:NSMakeRange(26, 2)]];
                
                [self.navigationController popToRootViewControllerAnimated:NO];
                
                PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:c];
                pp.delegate = self;
                [self.navigationController pushViewController:pp animated:YES];

            }
            break;
        }
        default:
            break;
    }
}

#pragma mark ScanViewControllerDelegate

- (void)scanResult:(UIViewController *)controller success:(BOOL)success result:(ZXResult *)result
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (success)
    {
        [self performSelector:@selector(processScanResult:) withObject:result afterDelay:.1];
    }
}

@end