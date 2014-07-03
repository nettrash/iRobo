//
//  FavoritesViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "FavoritesViewController_iPhone.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "svcFavorite.h"
#import "NSNumber+Currency.h"
#import "PayViewController_iPhone.h"

@interface FavoritesViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblFavorites;

@end

@implementation FavoritesViewController_iPhone

@synthesize tblFavorites = _tblFavorites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Favorites_Title", @"Favorites_Title");
        SWRevealViewController *revealViewController = [self revealViewController];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(changeEditMode:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tblFavorites.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 16, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 16);
    [self.view addSubview:self.tblFavorites.view];
    SWRevealViewController *revealViewController = [self revealViewController];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshFavorites:) forControlEvents:UIControlEventValueChanged];
    [self.tblFavorites setRefreshControl:refreshControl];
    [self.tblFavorites.refreshControl beginRefreshing];
    [self performSelector:@selector(refreshFavorites:) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshFavorites:(id)sender
{
    if (!self.tblFavorites.refreshControl.refreshing)
        [self.tblFavorites.refreshControl beginRefreshing];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetFavorites:self action:@selector(getFavoritesHandler:) UNIQUE:[app.userProfile uid] Hash:@""];
}

- (NSMutableArray *)getFavoritesByCurrency:(NSString *)currency
{
    for (NSMutableArray *a in _favorites) {
        if (a && a != nil && [a count] > 0 && [[(svcFavorite *)[a objectAtIndex:0] currency] isEqualToString:currency])
            return a;
    }
    return nil;
}

- (NSMutableArray *)getFavoritesBySection:(NSInteger)section
{
    return (NSMutableArray *)[_favorites objectAtIndex:section];
}

- (void)getFavoritesHandler:(id)response
{
    [self.tblFavorites.refreshControl endRefreshing];

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.favorites && resp.favorites != nil && [resp.favorites count] > 0)
            {
                _favorites = [NSMutableArray arrayWithCapacity:0];
                for (svcFavorite *f in resp.favorites) {
                    NSMutableArray *fa = [self getFavoritesByCurrency:f.currency];
                    if (fa == nil) {
                        fa = [NSMutableArray arrayWithCapacity:0];
                        [_favorites addObject:fa];
                    }
                    [fa addObject:f];
                }
                [self.tblFavorites.tableView reloadData];
            }
        }
    }
}

- (void)changeEditMode:(id)sender
{
    [self.tblFavorites setEditing:![self.tblFavorites isEditing] animated:YES];
}

- (void)deleteFavorite:(svcFavorite *)favorite
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"DeleteFavoriteWait", @"DeleteFavoriteWait")];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc RemoveFavorite:self action:@selector(deleteFavoriteHandler:) UNIQUE:[app.userProfile uid] favoriteId:[favorite favoriteId]];
}

- (void)deleteFavoriteHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            [self refreshFavorites:nil];
            return;
        }
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteFavorite_Title", @"DeleteFavorite_Title") message:NSLocalizedString(@"DeleteFavorites_ErrorMessage", @"DeleteFavorites_ErrorMessage") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
}

#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[(svcFavorite *)[[self getFavoritesBySection:section] objectAtIndex:0] currencyName] uppercaseString];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_favorites count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self getFavoritesBySection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteItemCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FavoriteItemCall"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    svcFavorite *f = (svcFavorite *)[[self getFavoritesBySection:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = f.favoriteName;
    cell.detailTextLabel.text = [f.summa numberWithCurrency];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", f.currency]];
    if (cell.imageView.image == nil)
        cell.imageView.image = [UIImage imageNamed:@"MainNoChecksIcon.png"];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:8];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    svcTopCurrency *curr = [[svcTopCurrency alloc] init];
    svcFavorite *f = (svcFavorite *)[[self getFavoritesBySection:indexPath.section] objectAtIndex:indexPath.row];
    curr.Label = f.currency;
    curr.Name = f.currencyName;
    curr.Parameters = f.parameters;
    curr.zeroComission = f.zeroComission;
    curr.OutPossibleValues = f.OutPossibleValues;
    PayViewController_iPhone *pp = [[PayViewController_iPhone alloc] initWithNibName:@"PayViewController_iPhone" bundle:nil withTopCurrency:curr andSumma:f.summa];
    pp.delegate = self;
    [self.navigationController pushViewController:pp animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [self deleteFavorite:(svcFavorite *)[[self getFavoritesBySection:indexPath.section] objectAtIndex:indexPath.row]];
            break;
        default:
            break;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"DeleteConfirmation_Title", @"DeleteConfirmation_Title");
}

#pragma mark PayViewControllerDelegate

- (void)finishPay:(UIViewController *)controller
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
