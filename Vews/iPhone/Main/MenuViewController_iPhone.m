//
//  MenuViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "MenuViewController_iPhone.h"
#import "SWRevealViewController.h"
#import "MainViewController_iPhone.h"
#import "FavoritesViewController_iPhone.h"
#import "TerminalsViewController_iPhone.h"
#import "CardsViewController_iPhone.h"
#import "HistoryViewController_iPhone.h"
#import "StatViewController_iPhone.h"
#import "ProfileViewController_iPhone.h"

@interface MenuViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblMenu;

@end

@implementation MenuViewController_iPhone

@synthesize tblMenu = _tblMenu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Menu_Title", @"Menu_Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = self.view.frame;
    frame.size.height -= 41;
    self.tblMenu.view.frame = frame;
    [self.view addSubview:self.tblMenu.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MenuItemCall"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: { // Платежи
                    cell.textLabel.text = NSLocalizedString(@"MenuItem_MainView_Title", @"MenuItem_MainView_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MenuItem_MainView_SubTitle", @"MenuItem_MainView_SubTitle");
                    cell.imageView.image = [UIImage imageNamed:NSLocalizedString(@"MenuItem_MainView_ImageName", @"MenuItem_MainView_ImageName")];
                    break;
                }
                case 1: { //Избранное
                    cell.textLabel.text = NSLocalizedString(@"MenuItem_FavoritesView_Title", @"MenuItem_FavoritesView_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MenuItem_FavoritesView_SubTitle", @"MenuItem_FavoritesView_SubTitle");
                    cell.imageView.image = [UIImage imageNamed:NSLocalizedString(@"MenuItem_FavoritesView_ImageName", @"MenuItem_FavoritesView_ImageName")];
                    break;
                }
                case 2: { //Терминалы
                    cell.textLabel.text = NSLocalizedString(@"MenuItem_TerminalsView_Title", @"MenuItem_TerminalsView_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MenuItem_TerminalsView_SubTitle", @"MenuItem_TerminalsView_SubTitle");
                    cell.imageView.image = [UIImage imageNamed:NSLocalizedString(@"MenuItem_TerminalsView_ImageName", @"MenuItem_TerminalsView_ImageName")];
                    break;
                }
                case 3: { //Карты
                    cell.textLabel.text = NSLocalizedString(@"MenuItem_CardsView_Title", @"MenuItem_CardsView_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MenuItem_CardsView_SubTitle", @"MenuItem_CardsView_SubTitle");
                    cell.imageView.image = [UIImage imageNamed:NSLocalizedString(@"MenuItem_CardsView_ImageName", @"MenuItem_CardsView_ImageName")];
                    break;
                }
                case 4: { //История
                    cell.textLabel.text = NSLocalizedString(@"MenuItem_HistoryView_Title", @"MenuItem_HistoryView_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MenuItem_HistoryView_SubTitle", @"MenuItem_HistoryView_SubTitle");
                    cell.imageView.image = [UIImage imageNamed:NSLocalizedString(@"MenuItem_HistoryView_ImageName", @"MenuItem_HistoryView_ImageName")];
                    break;
                }
                case 5: { //Статистика
                    cell.textLabel.text = NSLocalizedString(@"MenuItem_StatView_Title", @"MenuItem_StatView_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MenuItem_StatView_SubTitle", @"MenuItem_StatView_SubTitle");
                    cell.imageView.image = [UIImage imageNamed:NSLocalizedString(@"MenuItem_StatView_ImageName", @"MenuItem_StatView_ImageName")];
                    break;
                }
                case 6: { //Профиль
                    cell.textLabel.text = NSLocalizedString(@"MenuItem_SettingsView_Title", @"MenuItem_SettingsView_Title");
                    cell.detailTextLabel.text = NSLocalizedString(@"MenuItem_SettingsView_SubTitle", @"MenuItem_SettingsView_SubTitle");
                    cell.imageView.image = [UIImage imageNamed:NSLocalizedString(@"MenuItem_SettingsView_ImageName", @"MenuItem_SettingsView_ImageName")];
                    break;
                }
                default:
                    return nil;
            }
            break;
        }
        default:
            return nil;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    return cell;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealController = self.revealViewController;
    UINavigationController *frontNavigationController = (id)revealController.frontViewController;
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: { //Платежи
                    if ( ![frontNavigationController.topViewController isKindOfClass:[MainViewController_iPhone class]] )
                    {
                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController_iPhone alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil]];
                        [revealController pushFrontViewController:navigationController animated:YES];
                    }
                    break;
                }
                case 1: { //Избранное
                    if ( ![frontNavigationController.topViewController isKindOfClass:[FavoritesViewController_iPhone class]] )
                    {
                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[FavoritesViewController_iPhone alloc] initWithNibName:@"FavoritesViewController_iPhone" bundle:nil]];
                        [revealController pushFrontViewController:navigationController animated:YES];
                    }
                    break;
                }
                case 2: { //Терминалы
                    if ( ![frontNavigationController.topViewController isKindOfClass:[TerminalsViewController_iPhone class]] )
                    {
                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[TerminalsViewController_iPhone alloc] initWithNibName:@"TerminalsViewController_iPhone" bundle:nil]];
                        [revealController pushFrontViewController:navigationController animated:YES];
                    }
                    break;
                }
                case 3: { //Карты
                    if ( ![frontNavigationController.topViewController isKindOfClass:[CardsViewController_iPhone class]] )
                    {
                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[CardsViewController_iPhone alloc] initWithNibName:@"CardsViewController_iPhone" bundle:nil showUnauthorizedCards:YES withFormType:CardsViewFormTypeFullView]];
                        [revealController pushFrontViewController:navigationController animated:YES];
                    }
                    break;
                }
                case 4: { //История
                    if ( ![frontNavigationController.topViewController isKindOfClass:[HistoryViewController_iPhone class]] )
                    {
                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HistoryViewController_iPhone alloc] initWithNibName:@"HistoryViewController_iPhone" bundle:nil]];
                        [revealController pushFrontViewController:navigationController animated:YES];
                    }
                    break;
                }
                case 5: { //Статистика
                    if ( ![frontNavigationController.topViewController isKindOfClass:[StatViewController_iPhone class]] )
                    {
                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[StatViewController_iPhone alloc] initWithNibName:@"StatViewController_iPhone" bundle:nil]];
                        [revealController pushFrontViewController:navigationController animated:YES];
                    }
                    break;
                }
                case 6: { //Профиль
                    if ( ![frontNavigationController.topViewController isKindOfClass:[ProfileViewController_iPhone class]] )
                    {
                        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[ProfileViewController_iPhone alloc] initWithNibName:@"ProfileViewController_iPhone" bundle:nil]];
                        [revealController pushFrontViewController:navigationController animated:YES];
                    }
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
    [revealController revealToggle:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
