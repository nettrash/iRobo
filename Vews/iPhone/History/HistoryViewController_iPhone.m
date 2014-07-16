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
#import "HistoryPostToTwitterActivity.h"
#import "HistoryAddToFavoriteActivity.h"
#import "HistoryRemoveFromFavoriteActivity.h"
#import "AddToFavoriteViewController_iPhone.h"
#import "HistoryFinalizeCellView_iPhone.h"

@interface HistoryViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblHistory;
@property (nonatomic, retain) IBOutlet UISearchBar *sbPart;

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
        _activities = [NSArray arrayWithObjects:[[HistoryRepeatPaymentActivity alloc] initWithResultDelegate:self], [[HistoryBlankActivity alloc] initWithResultDelegate:self], [[HistoryAddToFavoriteActivity alloc] initWithResultDelegate:self], [[HistoryRemoveFromFavoriteActivity alloc] initWithResultDelegate:self], [[HistoryRequestSupportActivity alloc] initWithResultDelegate:self], [[HistoryPostToFacebookActivity alloc] initWithResultDelegate:self], [[HistoryPostToTwitterActivity alloc] initWithResultDelegate:self], nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshHistory:) forControlEvents:UIControlEventValueChanged];
    [self.tblHistory setRefreshControl:refreshControl];
    self.sbPart.frame = CGRectMake(0, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20, self.sbPart.frame.size.width, self.sbPart.frame.size.height);
    [self.view addSubview:self.sbPart];
    self.tblHistory.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 20 + self.sbPart.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20 - self.sbPart.frame.size.height);
    [self.view addSubview:self.tblHistory.view];
    [self.tblHistory.refreshControl beginRefreshing];
    [self performSelector:@selector(refreshHistory:) withObject:nil afterDelay:.1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshHistory:(id)sender
{
    [self.sbPart resignFirstResponder];
    _history = nil;
    _historyCache = nil;
    if (!self.tblHistory.refreshControl.refreshing)
        [self.tblHistory.refreshControl beginRefreshing];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetHistoryFromId:self action:@selector(getHistoryHandler:) UNIQUE:[app.userProfile uid] Id:-1 Count:_Count SearchText:self.sbPart.text];
    [self.tblHistory.tableView reloadData];
}

- (void)getHistory:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetHistoryFromId:self action:@selector(getHistoryHandler:) UNIQUE:[app.userProfile uid] Id:_Id Count:_Count SearchText:self.sbPart.text];
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
            }
            [self.tblHistory.tableView reloadData];
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
    [svc GetHistoryFromId:self action:@selector(getHistoryCacheHandler:) UNIQUE:[app.userProfile uid] Id:_Id Count:_Count SearchText:self.sbPart.text];
}

- (void)getHistoryCacheHandler:(id)response
{
    if (!_isLoadingCache) return;
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
            [self.tblHistory.tableView reloadData];
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

- (BOOL)isEqualParametersOperation:(svcHistoryOperation *) op toOperation:(svcHistoryOperation *)toOp
{
    if (![op.out_curr isEqualToString:toOp.out_curr])
        return NO;
    
    NSString *pa = op.op_Parameters;
    NSString *pb = toOp.op_Parameters;
    
    if ([pa hasSuffix:@";"])
        pa = [pa substringToIndex:[pa length] - 2];

    if ([pb hasSuffix:@";"])
        pb = [pb substringToIndex:[pb length] - 2];
    
    NSArray *a = [pa componentsSeparatedByString:@";"];
    NSArray *b = [pb componentsSeparatedByString:@";"];
    
    if (!a || a == nil || !b || b == nil || [a count] != [b count])
        return NO;
    
    for (int idx = 0; idx < [a count]; idx++)
    {
        NSString *as = (NSString *)[a objectAtIndex:idx];
        NSString *bs = (NSString *)[b objectAtIndex:idx];

        if (!as || as == nil || !bs || bs == nil)
            return NO;
        
        NSArray *aa = [as componentsSeparatedByString:@":"];
        NSArray *bb = [bs componentsSeparatedByString:@":"];
        
        if (!aa || aa == nil || !bb || bb == nil || [aa count] != [bb count] || [aa count] < 2 || [bb count] < 2)
            return NO;
        
        if (![(NSString *)[aa objectAtIndex:1] isEqualToString:(NSString *)[bb objectAtIndex:1]])
            return NO;
    }
    return YES;
}

- (void)removeFavoriteNames:(svcHistoryOperation *)op
{
    if (!op || op == nil) return;
    //Отправляем команду на удаление на сервер
    //Очищаем все похожие записи в текущей истории и кеше (если он есть)
    for (svcHistoryOperation *h in _history)
    {
        if ([self isEqualParametersOperation:op toOperation:h])
        {
            h.favoriteName = nil;
        }
    }
    if (_historyCache && _historyCache != nil)
    {
        for (svcHistoryOperation *h in _historyCache)
        {
            if ([self isEqualParametersOperation:op toOperation:h])
            {
                h.favoriteName = nil;
            }
        }
    }
    //Перегружаем данные в таблице
    [self.tblHistory.tableView reloadData];
    //Командуем удалить
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc RemoveFromFavorite:self action:@selector(removeFromFavoriteHandler:) UNIQUE:[app.userProfile uid] OpKey:op.op_Key];
}

- (void)removeFromFavorites:(svcHistoryOperation *)op
{
    if (!op || op == nil) return;
    //Отправляем команду на удаление на сервер
    //Очищаем все похожие записи в текущей истории и кеше (если он есть)
    for (svcHistoryOperation *h in _history)
    {
        if ([self isEqualParametersOperation:op toOperation:h])
        {
            h.inFavorites = NO;
        }
    }
    if (_historyCache && _historyCache != nil)
    {
        for (svcHistoryOperation *h in _historyCache)
        {
            if ([self isEqualParametersOperation:op toOperation:h])
            {
                h.inFavorites = NO;
            }
        }
    }
    //Перегружаем данные в таблице
    [self.tblHistory.tableView reloadData];
    //Командуем удалить
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc RemoveFromFavorite:self action:@selector(removeFromFavoriteHandler:) UNIQUE:[app.userProfile uid] OpKey:op.op_Key];
}

- (void)addToFavorites:(svcHistoryOperation *)op
{
    if (!op || op == nil) return;
    //Отправляем команду на удаление на сервер
    //Устанавливаем все похожие записи в текущей истории и кеше (если он есть)
    for (svcHistoryOperation *h in _history)
    {
        if ([self isEqualParametersOperation:op toOperation:h])
        {
            h.inFavorites = YES;
        }
    }
    if (_historyCache && _historyCache != nil)
    {
        for (svcHistoryOperation *h in _historyCache)
        {
            if ([self isEqualParametersOperation:op toOperation:h])
            {
                h.inFavorites = YES;
            }
        }
    }
    //Перегружаем данные в таблице
    [self.tblHistory.tableView reloadData];
}

- (void)addToFavorites:(svcHistoryOperation *)op withName:(NSString *)name
{
    if (!op || op == nil) return;
    //Отправляем команду на удаление на сервер
    //Устанавливаем все похожие записи в текущей истории и кеше (если он есть)
    for (svcHistoryOperation *h in _history)
    {
        if ([self isEqualParametersOperation:op toOperation:h])
        {
            h.inFavorites = YES;
            h.favoriteName = name;
        }
    }
    if (_historyCache && _historyCache != nil)
    {
        for (svcHistoryOperation *h in _historyCache)
        {
            if ([self isEqualParametersOperation:op toOperation:h])
            {
                h.inFavorites = YES;
                h.favoriteName = name;
            }
        }
    }
    //Перегружаем данные в таблице
    [self.tblHistory.tableView reloadData];
}

- (svcHistoryOperation *)operationWithOpKey:(NSString *)OpKey
{
    for (svcHistoryOperation *h in _history) {
        if ([h.op_Key isEqualToString:OpKey])
            return h;
    }
    return nil;
}

- (void)removeFromFavoriteHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            [self removeFavoriteNames:[self operationWithOpKey:resp.OpKey]];
            return;
        }
        //Обратно помечаем как принадлежащие избранному
        [self addToFavorites:[self operationWithOpKey:resp.OpKey]];
    }
    //Ошибка удаления
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RemoveFromFavorite_Title", @"RemoveFromFavorite_Title") message:NSLocalizedString(@"RemoveFromFavorite_ErrorMessage", @"RemoveFromFavorite_ErrorMessage") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_history count] > 0)
        return [_history count] + 1;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [_history count]) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HistoryFinalizeCellView_iPhone" owner:self options:nil];
        HistoryFinalizeCellView_iPhone *cell = (HistoryFinalizeCellView_iPhone *)[nib objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (_isLoadingCache || _historyCache != nil) {
            [cell.aiWait startAnimating];
            cell.lblMessage.hidden = YES;
        } else {
            [cell.aiWait stopAnimating];
            cell.lblMessage.hidden = NO;
        }
        return cell;
    } else {
        if (_selectedIndexPath && [_selectedIndexPath compare:indexPath] == NSOrderedSame) {
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
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.sbPart resignFirstResponder];
    if (indexPath.row >= [_history count]) return;
    
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
    if (indexPath.row >= [_history count]) {
        return 44;
    } else {
        if (_selectedIndexPath && [_selectedIndexPath compare:indexPath] == NSOrderedSame)
        {
            return 188;
        }
        return 100;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [_history count]) return;
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
    if ([activity isKindOfClass:[HistoryRemoveFromFavoriteActivity class]]) {
        [self removeFromFavorites:(svcHistoryOperation *)data];
        return;
    }
    if ([activity isKindOfClass:[HistoryAddToFavoriteActivity class]]) {
        svcHistoryOperation *op = (svcHistoryOperation *)data;
        AddToFavoriteViewController_iPhone *pp = [[AddToFavoriteViewController_iPhone alloc] initWithNibName:@"AddToFavoriteViewController_iPhone" bundle:nil withOperation:op];
        pp.delegate = self;
        [self.navigationController pushViewController:pp animated:YES];
        return;
    }
}

#pragma mark OperationBlankDelegate

- (void)finishBlankWork:(UIViewController *)controller
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark AddToFavoriteDelegate

- (void)addToFavorite:(UIViewController *)controller operation:(svcHistoryOperation *)op withName:(NSString *)name andSumm:(NSDecimalNumber *)summa
{
    [self addToFavorites:op withName:name];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAddToFavorite:(UIViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UISearchBarDelegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
    _isLoadingCache = NO;
    [self refreshHistory:nil];
}

@end
