//
//  MessagesViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "MessagesViewController_iPhone.h"
#import "SWRevealViewController.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"
#import "svcMessage.h"
#import "MessageCell_iPhone.h"

@interface MessagesViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblMessages;

@end

@implementation MessagesViewController_iPhone

@synthesize tblMessages = _tblMessages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _timestamp = @"";
        _messages = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    //refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"RefreshMessages_Title", @"RefreshMessages_Title")];
    //refreshControl.tintColor = [UIColor darkGrayColor];
    [refreshControl addTarget:self action:@selector(refreshMessages:) forControlEvents:UIControlEventValueChanged];
    [self.tblMessages setRefreshControl:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect frame = self.view.frame;
    frame.size.width -= 60;
    frame.origin.x += 60;
    frame.origin.y += 24;
    frame.size.height -= 24;
    self.tblMessages.view.frame = frame;
    [self.view addSubview:self.tblMessages.view];
    [self.tblMessages.refreshControl beginRefreshing];
    [self performSelector:@selector(refreshMessages:) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshMessages:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetMessages:self action:@selector(getMessagesHandler:) UNIQUE:[app.userProfile uid] TIMESTAMP:_timestamp];
}

- (void)getMessagesHandler:(id)response
{
    [self.tblMessages.refreshControl endRefreshing];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (_timestamp == nil || [_timestamp isEqualToString:@""])
            {
                _messages = [NSMutableArray arrayWithArray:resp.messages];
            }
            else
            {
                NSMutableArray *a = [NSMutableArray arrayWithArray:resp.messages];
                NSMutableArray *b = [NSMutableArray arrayWithArray:_messages];
                _messages = [NSMutableArray arrayWithArray:a];
                [_messages addObjectsFromArray:b];
            }
            _timestamp = [NSString stringWithString:resp.messagesVersion];
            [self.tblMessages.tableView reloadData];
        }
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_messages != nil)
        return [_messages count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndexPath && [_selectedIndexPath compare:indexPath] == NSOrderedSame)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell_iPhone" owner:self options:nil];
        MessageCell_iPhone *cell = (MessageCell_iPhone *)[nib objectAtIndex:0];
        
        svcMessage *m = (svcMessage *)[_messages objectAtIndex:indexPath.row];
        cell.textLabel.text = m.Title;
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:m.RegDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
        cell.messageTextLabel.text = m.Body;
        
        if (m.URL != nil && ![m.URL isEqualToString:@""])
            cell.imageView.image = [UIImage imageNamed:@"WWW"];
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"Success"];
            if ([m.Mood isEqualToString:@"Info"])
            {
                cell.imageView.image = [UIImage imageNamed:@"Information"];
            }
            if ([m.Mood isEqualToString:@"Fail"])
            {
                cell.imageView.image = [UIImage imageNamed:@"Fail"];
            }
        }
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:8];
        cell.messageTextLabel.font = [UIFont systemFontOfSize:10];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
        [cell.messageTextLabel setTextColor:[UIColor darkGrayColor]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell"];
    
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MenuItemCall"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
        svcMessage *m = (svcMessage *)[_messages objectAtIndex:indexPath.row];
        cell.textLabel.text = m.Title;
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:m.RegDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
            
        if (m.URL != nil && ![m.URL isEqualToString:@""])
            cell.imageView.image = [UIImage imageNamed:@"WWW"];
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"Success"];
            if ([m.Mood isEqualToString:@"Info"])
            {
                cell.imageView.image = [UIImage imageNamed:@"Information"];
            }
            if ([m.Mood isEqualToString:@"Fail"])
            {
                cell.imageView.image = [UIImage imageNamed:@"Fail"];
            }
        }

        cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:8];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
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
        return 132;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *ip = _selectedIndexPath;
    _selectedIndexPath = nil;
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:ip, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

@end
