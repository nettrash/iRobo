//
//  HistoryViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "HistoryViewController_iPhone.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "svcHistoryOperation.h"
#import "NSNumber+Currency.h"
#import "PayViewController_iPhone.h"
#import "svcTopCurrency.h"
#import "HistoryCellView_iPhone.h"
#import "SelectedHistoryCellView_iPhone.h"
#import "HistoryRequestSupportActivity.h"
#import "HistoryRepeatPaymentActivity.h"
#import "HistoryPostToFacebookActivity.h"
#import "HistoryBlankActivity.h"
#import "BlankViewController_iPhone.h"

@interface HistoryViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblHistory;

@end

@implementation HistoryViewController_iPhone

@synthesize tblHistory = _tblHistory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _Id = -1;
        _Count = 25;
        self.navigationItem.title = NSLocalizedString(@"History_Title", @"History_Title");
        SWRevealViewController *revealViewController = [self revealViewController];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        _activities = [NSArray arrayWithObjects:[[HistoryRepeatPaymentActivity alloc] initWithResultDelegate:self], [[HistoryBlankActivity alloc] initWithResultDelegate:self], [[HistoryRequestSupportActivity alloc] initWithResultDelegate:self], [[HistoryPostToFacebookActivity alloc] initWithResultDelegate:self], nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tblHistory.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 16, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 16);
    [self.view addSubview:self.tblHistory.view];
    SWRevealViewController *revealViewController = [self revealViewController];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshHistory:) forControlEvents:UIControlEventValueChanged];
    [self.tblHistory setRefreshControl:refreshControl];
    [self.tblHistory.refreshControl beginRefreshing];
    [self performSelector:@selector(refreshHistory:) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshHistory:(id)sender
{
    _history = nil;
    _historyCache = nil;
    if (!self.tblHistory.refreshControl.refreshing)
        [self.tblHistory.refreshControl beginRefreshing];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetHistoryFromId:self action:@selector(getHistoryHandler:) UNIQUE:[app.userProfile uid] Id:-1 Count:_Count];
}

- (void)getHistory:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetHistoryFromId:self action:@selector(getHistoryHandler:) UNIQUE:[app.userProfile uid] Id:_Id Count:_Count];
}

- (void)getHistoryHandler:(id)response
{
    [self.tblHistory.refreshControl endRefreshing];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.history && resp.history != nil && [resp.history count] > 0)
            {
                if (!_history || _history == nil)
                    _history = [NSMutableArray arrayWithCapacity:0];
                [_history addObjectsFromArray:resp.history];
                _Id = [(svcHistoryOperation *)[_history objectAtIndex:[_history count] - 1] op_Id];
                if (_historyCache == nil)
                    [self performSelector:@selector(getHistoryCache:) withObject:nil afterDelay:1];
                else
                {
                    if ([(svcHistoryOperation *)[_historyCache objectAtIndex:[_historyCache count] - 1] op_Id] >= _Id)
                        [self performSelector:@selector(getHistoryCache:) withObject:nil afterDelay:1];
                }
                [self.tblHistory.tableView reloadData];
            }
        }
    }
}

- (void)getHistoryCache:(id)sender
{
    if (_isLoadingCache) return;
    if (_historyCache && _historyCache != nil && [(svcHistoryOperation *)[_historyCache objectAtIndex:[_historyCache count] - 1] op_Id] < _Id) return;
    _isLoadingCache = YES;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetHistoryFromId:self action:@selector(getHistoryCacheHandler:) UNIQUE:[app.userProfile uid] Id:_Id Count:_Count];
}

- (void)getHistoryCacheHandler:(id)response
{
    _isLoadingCache = NO;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.history && resp.history != nil && [resp.history count] > 0)
            {
                if (!_historyCache || _historyCache == nil)
                    _historyCache = [NSMutableArray arrayWithCapacity:0];
                [_historyCache addObjectsFromArray:resp.history];
            }
        }
    }
}

- (void)useHistoryCache
{
    if (!_historyCache || _historyCache == nil) return;
    if (_isLoadingCache) return;
    [_history addObjectsFromArray:_historyCache];
    _Id = [(svcHistoryOperation *)[_history objectAtIndex:[_history count] - 1] op_Id];
    _historyCache = nil;
    [self.tblHistory.tableView reloadData];
    [self getHistoryCache:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndexPath && [_selectedIndexPath compare:indexPath] == NSOrderedSame)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SelectedHistoryCellView_iPhone" owner:self options:nil];
        SelectedHistoryCellView_iPhone *cell = (SelectedHistoryCellView_iPhone *)[nib objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        svcHistoryOperation *op = (svcHistoryOperation *)[_history objectAtIndex:indexPath.row];
        if (indexPath.row > [_history count] - (_Count / 2))
            [self performSelector:@selector(useHistoryCache) withObject:nil afterDelay:.3];
        
        [cell setCellData:op withActivities:_activities];
        
        return cell;
    }
    else
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HistoryCellView_iPhone" owner:self options:nil];
        HistoryCellView_iPhone *cell = (HistoryCellView_iPhone *)[nib objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        svcHistoryOperation *op = (svcHistoryOperation *)[_history objectAtIndex:indexPath.row];
        if (indexPath.row > [_history count] - (_Count / 2))
            [self performSelector:@selector(useHistoryCache) withObject:nil afterDelay:.3];
        
        [cell setCellData:op];
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *ip = _selectedIndexPath;
    _selectedIndexPath = indexPath;
    
    if ([_selectedIndexPath compare:ip] == NSOrderedSame)
    {
        _selectedIndexPath = nil;
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:ip, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
    else
    {
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_selectedIndexPath, ip, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndexPath && [_selectedIndexPath compare:indexPath] == NSOrderedSame)
    {
        return 176;
    }
    return 88;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *ip = _selectedIndexPath;
    _selectedIndexPath = nil;
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:ip, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

#pragma mark PayViewControllerDelegate

- (void)finishPay:(UIViewController *)controller
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark ActivityResultDelegate

- (void)activityStart:(id)obj
{
}

- (void)activityEnd:(id)obj
{
}

- (void)doActivityParentAction:(id)activity withData:(id)data
{
    if ([activity isKindOfClass:[HistoryRepeatPaymentActivity class]]) {
        svcHistoryOperation *op = (svcHistoryOperation *)data;
        svcTopCurrency *curr = [[svcTopCurrency alloc] init];
        curr.Label = op.out_curr;
        curr.Name = op.currName;
        curr.Parameters = op.op_Parameters;
        curr.zeroComission = op.zeroComission;
        curr.OutPossibleValues = op.OutPossibleValues;
        PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:curr andSumma:op.op_Sum];
        pp.delegate = self;
        [self.navigationController pushViewController:pp animated:YES];
        return;
    }
    if ([activity isKindOfClass:[HistoryBlankActivity class]]) {
        svcHistoryOperation *op = (svcHistoryOperation *)data;
        BlankViewController_iPhone *pp = [[BlankViewController_iPhone alloc] initWithNibName:@"BlankViewController_iPhone" bundle:nil withOperation:op];
        pp.delegate = self;
        [self.navigationController pushViewController:pp animated:YES];
        return;
    }
}

#pragma mark BlankViewControllerDelegate

- (void)finishBlankWork:(UIViewController *)controller
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
