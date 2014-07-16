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
#import "NSString+Checkers.h"
#import "NSString+RegEx.h"
#import "PayCharityViewController_iPhone.h"
#import "UIAlertWithInternetSearchDelegate.h"
#import "QRViewController_iPhone.h"

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
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        if ([videoDevices count] > 0)
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
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if ([videoDevices count] > 0)
    {
        ScanViewController_iPhone *v = [[ScanViewController_iPhone alloc] initWithNibName:@"ScanViewController_iPhone" bundle:nil delegate:self];
        [self presentViewController:v animated:YES completion:nil];
    }
}

- (void)receiveByQR:(id)sender
{
    //Отправляем выбирать карту
    //Далее отправляем на код
    CardsViewController_iPhone *cc = [[CardsViewController_iPhone alloc] initWithNibName:@"CardsViewController_iPhone" bundle:nil showUnauthorizedCards:NO withFormType:CardsViewFormTypeSelectView];
    cc.delegate = self;
    [self.navigationController pushViewController:cc animated:YES];
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
    if (!_checksRefreshing && !_topCatalogRefreshing) {
        [self.tblPayments.refreshControl endRefreshing];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] firstTimeInitializationComplete];
    }
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
    if (!_checksRefreshing && !_topCatalogRefreshing) {
        [self.tblPayments.refreshControl endRefreshing];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] firstTimeInitializationComplete];
    }
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
            NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            if ([videoDevices count] > 0)
                return 5;
            return 4;
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
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
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
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_ReceiveByQR_Title", @"MainTable_Section_Helpers_ReceiveByQR_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_ReceiveByQR_Details", @"MainTable_Section_Helpers_ReceiveByQR_Details");
                    cell.imageView.image = [UIImage imageNamed:@"MainQRIcon.png"];
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 4: {
                    cell.textLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_Scan_Title", @"MainTable_Section_Helpers_Scan_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MainTable_Section_Helpers_Scan_Details", @"MainTable_Section_Helpers_Scan_Details");
                    cell.imageView.image = [UIImage imageNamed:@"MainScanIcon.png"];
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
                        cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];
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
            if (_checks && _checks != nil && [_checks count] > 0 && !_checksRefreshing)
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
                    PayPhoneViewController_iPhone *pp = [[PayPhoneViewController_iPhone alloc] initWithNibName:IS_IPHONE_5 ? @"PayPhoneViewController_iPhone" : @"PayPhoneViewController_iPhone4" bundle:nil];
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
                    [self receiveByQR:nil];
                    break;
                }
                case 4: {
                    [self scan:nil];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2: {
            if (!_topCatalogRefreshing) {
                svcTopCurrency *curr = (svcTopCurrency *)[_topCatalog objectAtIndex:indexPath.row];
                PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:curr];
                pp.delegate = self;
                [self.navigationController pushViewController:pp animated:YES];
            }
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
    [self.tblPayments.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
            [self.tblPayments.tableView reloadData];
            for (svcCheck *c in resp.checks)
            {
                if (c.checkId == resp.checkId)
                {
                    PayCheckViewController_iPhone *pp = [[PayCheckViewController_iPhone alloc] initWithNibName:@"PayCheckViewController_iPhone" bundle:nil withCheck:c];
                    pp.delegate = self;
                    [self.navigationController pushViewController:pp animated:YES];
                    return;
                }
            }
        }
    }
}

- (void)payCharity:(NSString *)CharityID
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"PayCharityByCommand_WaitMessage", @"PayCharityByCommand_WaitMessage")];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetCharity:self action:@selector(payCharityHandler:) UNIQUE:[app.userProfile uid] charityId:[CharityID intValue]];
}

- (void)c2cTransfer:(NSString *)toCard
{
    Card2CardTransferViewController_iPhone *cc = [[Card2CardTransferViewController_iPhone alloc] initWithNibName:@"Card2CardTransferViewController_iPhone" bundle:nil withToCardNumber:toCard];
    cc.delegate = self;
    [self.navigationController pushViewController:cc animated:YES];
}

- (void)payCharityHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.charity && resp.charity != nil)
            {
                PayCharityViewController_iPhone *pp = [[PayCharityViewController_iPhone alloc] initWithNibName:@"PayCharityViewController_iPhone" bundle:nil withCharity:resp.charity];
                pp.delegate = self;
                [self.navigationController pushViewController:pp animated:YES];
                return;
            }
        }
    }
}

#pragma mark ScanProcessing

- (void)processScanResult:(AVMetadataMachineReadableCodeObject *)result
{
    NSLog(@"%@", result.type);
    NSString *resultText = [result stringValue];
    if ([result.type isEqualToString:@"org.iso.QRCode"])
    {
        if ([resultText isRobodQRCommand])
        {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app performSelector:@selector(applyScanedURL:) withObject:[NSURL URLWithString:resultText] afterDelay:.1];
            return;
        }
        else
        {
            if ([resultText isVCARD]) {
                CFDataRef vCardData = (__bridge CFDataRef)[resultText dataUsingEncoding:NSUTF8StringEncoding];
                
                ABRecordRef vCardPerson = ABPersonCreate();
                
                CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(vCardPerson, vCardData);
                
                for (CFIndex i = 0; i < CFArrayGetCount(vCardPeople); ++i) {
                    vCardPerson = CFArrayGetValueAtIndex(vCardPeople, i);
                    break;
                }
                
                CFRelease(vCardPeople);
                
                ABUnknownPersonViewController *picker = [[ABUnknownPersonViewController alloc] init];
                picker.unknownPersonViewDelegate = self;
                picker.displayedPerson = vCardPerson;
                picker.allowsAddingToAddressBook = YES;
                picker.allowsActions = YES;
                picker.title = NSLocalizedString(@"QRPerson", @"QRPerson");
                [self.navigationController pushViewController:picker animated:YES];
                return;
            }
            //Проверяем на тип URL
            if ([resultText isURL]) {
                _openURLDelegate = [UIAlertWithOpenURLDelegate initWithText:resultText];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OpenURL_Title", @"OpenURL_Title") message:[NSString stringWithFormat:NSLocalizedString(@"OpenURL_Message", @"OpenURL_Message"), _openURLDelegate.url.host] delegate:_openURLDelegate cancelButtonTitle:NSLocalizedString(@"Button_Cancel", @"Button_Cancel") otherButtonTitles:NSLocalizedString(@"Button_OpenURL", @"Button_OpenURL"), nil];
                [alert show];
                return;
            }
        }
    }
    if ([result.type isEqualToString:@"org.iso.Code39"])
    {
        if ([resultText isPossibleMGTS]) {
            /*
             МГТС
             
             Label QiwiS31
             Name МГТС
             P5918_account Номер телефона
             
             OutPossibleValue сумма через ;
             
             Пример 495420050901250048100
             
             Номер 4954200509
             Квартира 0125
             Сумма 0048100
             */
            svcTopCurrency *c = [svcTopCurrency alloc];
            c.Label = @"QiwiS31";
            c.Name = @"МГТС";
            c.Parameters = [NSString stringWithFormat:@"P5918_account:%@", [resultText substringWithRange:NSMakeRange(0, 10)]];
            c.OutPossibleValues = [NSString stringWithFormat:@"%i.%@;", [[resultText substringWithRange:NSMakeRange(14, 5)] intValue], [resultText substringWithRange:NSMakeRange(19, 2)]];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:c];
            pp.delegate = self;
            [self.navigationController pushViewController:pp animated:YES];
            return;
        }
        if ([resultText isPossibleMosenergosbut]) {
            /*
             МОСЭНЕРГОСБЫТ
             
             Label QiwiS330
             Name Мосэнергосбыт
             P86259_account Номер лицевого счета
             
             OutPossibleValues сумма через ;
             
             Пример 1996120112505301371110649
             
             Код РР 199
             Лицевой счет 61201125
             
             053 - Не ясно что это
             
             Рубли 01371
             Копейки 11
             Код платежа 06
             
             49 - не ясно что это такое
             */
            svcTopCurrency *c = [svcTopCurrency alloc];
            c.Label = @"QiwiS330";
            c.Name = @"Мосэнергосбыт";
            c.Parameters = [NSString stringWithFormat:@"P86259_account:%@", [resultText substringWithRange:NSMakeRange(3, 8)]];
            c.OutPossibleValues = [NSString stringWithFormat:@"%i.%@;", [[resultText substringWithRange:NSMakeRange(14, 5)] intValue], [resultText substringWithRange:NSMakeRange(19, 2)]];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:c];
            pp.delegate = self;
            [self.navigationController pushViewController:pp animated:YES];
            return;
        }
    }
    if ([result.type isEqualToString:@"org.iso.Code128"])
    {
        if ([resultText isPossibleMoscowGKU]) {
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
            c.Parameters = [NSString stringWithFormat:@"P5929_account[0]:%@;P5929_account[1]:%@", [resultText substringWithRange:NSMakeRange(0, 10)], [resultText substringWithRange:NSMakeRange(10, 4)]];
            c.OutPossibleValues = [NSString stringWithFormat:@"%i.%@;%i.%@", [[resultText substringWithRange:NSMakeRange(14, 5)] intValue], [resultText substringWithRange:NSMakeRange(19, 2)], [[resultText substringWithRange:NSMakeRange(21, 5)] intValue], [resultText substringWithRange:NSMakeRange(26, 2)]];
            
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:c];
            pp.delegate = self;
            [self.navigationController pushViewController:pp animated:YES];
            return;
        }
        if ([resultText isPossibleGIBDD]) {
            /*
             Штраф ГИБДД
             
             Label
             Name
             P...
             
             OutPossibleValues ...
             
             Пример 18810168140430001964
             */
        }
    }
    //А пока сообщаем что данный тип кода не поддерживается
    [self showUnsupportedCode:resultText];
}

- (void)showUnsupportedCode:(NSString *)Q
{
    _internetSearchDelegate = [UIAlertWithInternetSearchDelegate initWithQ:Q];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UnsupportedCode_Title", @"UnsupportedCode_Title") message:NSLocalizedString(@"UnsupportedCode_Message", @"UnsupportedCode_Message") delegate:_internetSearchDelegate cancelButtonTitle:NSLocalizedString(@"Button_Cancel", @"Button_Cancel") otherButtonTitles:NSLocalizedString(@"Button_YandexSearch", @"Button_YandexSearch"), NSLocalizedString(@"Button_GoogleSearch", @"Button_GoogleSearch"), NSLocalizedString(@"Button_BingSearch", @"Button_BingSearch"), nil];
    [alert show];
}

#pragma mark ScanViewControllerDelegate

- (void)scanResult:(UIViewController *)controller success:(BOOL)success result:(AVMetadataMachineReadableCodeObject *)result
{
    [self dismissViewControllerAnimated:NO completion:nil];
    if (success)
    {
        [self performSelector:@selector(processScanResult:) withObject:result afterDelay:.1];
    }
}

#pragma mark ABUnknownPersonViewControllerDelegate methods

- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark CardsViewControllerDelegate

- (void)cardSelected:(svcCard *)card controller:(UIViewController *)controller
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    QRViewController_iPhone *qr = [[QRViewController_iPhone alloc] initWithNibName:@"QRViewController_iPhone" bundle:nil withSource:[NSString stringWithFormat:@"card2card://to_card/%@", card.card_NativeNumber] andWidth:self.view.frame.size.width];
    [self.navigationController pushViewController:qr animated:YES];
}

@end
