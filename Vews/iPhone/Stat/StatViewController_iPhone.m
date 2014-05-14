//
//  StatViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "StatViewController_iPhone.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "svcDeviceStatItem.h"
#import "NSNumber+Currency.h"
#import "NSDate+MonthNames.h"
#import "SWRevealViewController.h"

@interface StatViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblStat;

@end

@implementation StatViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Stat_Title", @"Stat_Title");
        _statItems = nil;
        SWRevealViewController *revealViewController = [self revealViewController];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getStat:) forControlEvents:UIControlEventValueChanged];
    [self.tblStat setRefreshControl:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tblStat.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 16, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 16);
    [self.view addSubview:self.tblStat.view];
    [self.tblStat.refreshControl beginRefreshing];
    [self performSelector:@selector(getStat:) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)getStat:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetDeviceStat:self action:@selector(getDeviceStatHandler:) UNIQUE:[app.userProfile uid]];
}

- (void)getDeviceStatHandler:(id)response
{
    [self.tblStat.refreshControl endRefreshing];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.deviceStat && resp.deviceStat != nil && [resp.deviceStat count] > 0)
            _statItems = resp.deviceStat;
            [self.tblStat.tableView reloadData];
        }
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_statItems && _statItems != nil && [_statItems count] > 0)
        return [_statItems count];
    else
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    svcDeviceStatItem *item = (svcDeviceStatItem *)[_statItems objectAtIndex:section];
    return item.provider;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *now = [NSDate date];
    NSDate *prev = [now addMonth:-1];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatItemCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"StatItemCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    svcDeviceStatItem *item = (svcDeviceStatItem *)[_statItems objectAtIndex:indexPath.section];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [now monthName], [item.currentMonthSum numberWithCurrency]];
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"Операций: %i", item.currentMonthCount];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [prev monthName], [item.prevMonthSum numberWithCurrency]];
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"Операций: %i", item.prevMonthCount];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"usualy_in_month", @"usualy_in_month"), [item.avgMonthSum numberWithCurrency]];
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"Операций: %i", item.avgMonthCount];
            break;
        default:
            break;
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    return cell;
}

@end
