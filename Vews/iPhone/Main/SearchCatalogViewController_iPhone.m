//
//  SearchCatalogViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 08.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "SearchCatalogViewController_iPhone.h"
#import "svcTopCurrency.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"
#import "NSNumber+Currency.h"

@interface SearchCatalogViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblCatalog;
@property (nonatomic, retain) IBOutlet UISearchBar *sbPart;

@end

@implementation SearchCatalogViewController_iPhone

@synthesize delegate = _delegate;
@synthesize tblCatalog = _tblCatalog;
@synthesize sbPart = _sbPart;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _catalog = nil;
        _firstSearch = YES;
        _isRefreshing = NO;
        self.navigationItem.title = NSLocalizedString(@"SearchCatalog_Title", @"SearchCatalog_Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sbPart.frame = CGRectMake(0, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20, self.sbPart.frame.size.width, self.sbPart.frame.size.height);
    [self.view addSubview:self.sbPart];
    self.tblCatalog.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20 + self.sbPart.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20 - self.sbPart.frame.size.height);
    [self.view addSubview:self.tblCatalog.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.sbPart becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)searchCatalogHandler:(id)response
{
    _isRefreshing = NO;
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            _catalog = resp.topcatalog;
            [self.tblCatalog.tableView reloadData];
            if (_catalog == nil || [_catalog count] == 0)
                [self.sbPart becomeFirstResponder];
            return;
        }
    }
    [self.sbPart becomeFirstResponder];
}

- (void)search:(id)sender
{
    _firstSearch = NO;
    _isRefreshing = YES;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc SearchCatalog:self action:@selector(searchCatalogHandler:) UNIQUE:[app.userProfile uid] Part:self.sbPart.text];
    
    [self.tblCatalog.tableView reloadData];
}

- (NSString *)convertToPossibleString:(NSString *)opv
{
    if (opv == nil || [opv isEqualToString:@""])
        return NSLocalizedString(@"OutPossibleValues_NotSet", @"OutPossibleValues_NotSet");
    else
    {
        NSArray *groups = [opv componentsSeparatedByString:@";"];
        for (NSString *group in groups) {
            if (group == nil || [group isEqualToString:@""])
            {
                return NSLocalizedString(@"OutPossibleValues_NotSet", @"OutPossibleValues_NotSet");
            }
            else
            {
                NSArray *min_max = [group componentsSeparatedByString:@"-"];
                if ([min_max count] == 1)
                {
                    return NSLocalizedString(@"OutPossibleValues_FixedSums", @"OutPossibleValues_FixedSums");
                }
                else
                {
                    NSString *sMin = [min_max objectAtIndex:0];
                    NSString *sMax = [min_max objectAtIndex:1];
                    if ([sMax isEqualToString:@""])
                    {
                        NSDecimalNumber *min = [NSDecimalNumber decimalNumberWithString:sMin];
                        return [NSString stringWithFormat:NSLocalizedString(@"OutPossibleValues_Min", @"OutPossibleValues_Min"), [[[min numberWithCurrency] stringByReplacingOccurrencesOfString:NSLocalizedString(@"rub2", @"rub2") withString:NSLocalizedString(@"rub5", @"rub5")] stringByReplacingOccurrencesOfString:NSLocalizedString(@"rub1", @"rub1") withString:NSLocalizedString(@"rub2", @"rub2")]];
                    }
                    else
                    {
                        if ([sMin isEqualToString:@""])
                        {
                            NSDecimalNumber *max = [NSDecimalNumber decimalNumberWithString:sMax];
                            return [NSString stringWithFormat:NSLocalizedString(@"OutPossibleValues_Max", @"OutPossibleValues_Max"), [[[max numberWithCurrency] stringByReplacingOccurrencesOfString:NSLocalizedString(@"rub2", @"rub2") withString:NSLocalizedString(@"rub5", @"rub5")] stringByReplacingOccurrencesOfString:NSLocalizedString(@"rub1", @"rub1") withString:NSLocalizedString(@"rub2", @"rub2")]];
                        }
                        else
                        {
                            NSDecimalNumber *min = [NSDecimalNumber decimalNumberWithString:sMin];
                            NSDecimalNumber *max = [NSDecimalNumber decimalNumberWithString:sMax];
                            return [NSString stringWithFormat:NSLocalizedString(@"OutPossibleValues_MinMax", @"OutPossibleValues_MinMax"), [[[min numberWithCurrency] stringByReplacingOccurrencesOfString:NSLocalizedString(@"rub2", @"rub2") withString:NSLocalizedString(@"rub5", @"rub5")] stringByReplacingOccurrencesOfString:NSLocalizedString(@"rub1", @"rub1") withString:NSLocalizedString(@"rub2", @"rub2")], [[[max numberWithCurrency] stringByReplacingOccurrencesOfString:NSLocalizedString(@"rub2", @"rub2") withString:NSLocalizedString(@"rub5", @"rub5")] stringByReplacingOccurrencesOfString:NSLocalizedString(@"rub1", @"rub1") withString:NSLocalizedString(@"rub2", @"rub2")]];
                        }
                    }
                }
            }
        }
    }
    return @"";
}

#pragma mark UISearchBarDelegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
    [self search:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";//NSLocalizedString(@"SearchCatalog_Section_Result", @"SearchCatalog_Section_Result");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isRefreshing) return 1;
    if (_catalog && _catalog != nil && [_catalog count] > 0)
        return [_catalog count];
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (_isRefreshing)
    {
        cell.textLabel.text = NSLocalizedString(@"SearchCatalog_Refresh_Title", @"SearchCatalog_Refresh_Title");
        cell.detailTextLabel.text = NSLocalizedString(@"SearchCatalog_Refresh_Details", @"SearchCatalog_Refresh_Details");
        UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        ai.hidesWhenStopped = YES;
        [ai startAnimating];
        cell.accessoryView = ai;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        if (_catalog && _catalog != nil && [_catalog count] > 0)
        {
            svcTopCurrency *cur = (svcTopCurrency *)[_catalog objectAtIndex:indexPath.row];
    
            cell.textLabel.text = [cur.Name uppercaseString];
            cell.detailTextLabel.text = [self convertToPossibleString:cur.OutPossibleValues];
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            /*cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", cur.Label]];
            if (cell.imageView.image == nil)
                cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];;
            */
            cell.imageView.image = nil;
        }
        else
        {
            if (_firstSearch)
            {
                cell.textLabel.text = @"";
                cell.detailTextLabel.text = @"";
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"SearchCatalog_NotFound_Title", @"SearchCatalog_NotFound_Title");
                cell.detailTextLabel.text = NSLocalizedString(@"SearchCatalog_NotFound_Details", @"SearchCatalog_NotFound_Details");
                cell.accessoryView = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
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
    if (!_isRefreshing && _catalog && _catalog != nil && [_catalog count] > 0) {
        [self.delegate searchResult:self withCurrency:(svcTopCurrency *)[_catalog objectAtIndex:indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
