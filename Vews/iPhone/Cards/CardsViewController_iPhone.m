//
//  CardsViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 15.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardsViewController_iPhone.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"
#import "svcCard.h"
#import "NSNumber+Currency.h"
#import "NSNumber+MonthNames.h"
#import "AddCardViewController_iPhone.h"
#import "CardRefreshBalanceActivity.h"
#import "CardMoneySendActivity.h"
#import "CardReceiveMoneyActivity.h"
#import "CardRequestSupportActivity.h"
#import "CardCallSupportActivity.h"
#import "CardAuthorizeActivity.h"
#import "UIViewController+KeyboardExtensions.h"
#import "ActivityAction.h"
#import "CardCellView_iPhone.h"
#import "SelectedCardCellView_iPhone.h"

@interface CardsViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITableViewController *tblCards;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *trash;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *action;
@property (nonatomic, retain) svcCard *activeCard;

- (IBAction)addCard:(id)sender;
- (IBAction)removeCard:(id)sender;
- (IBAction)cardAction:(id)sender;

@end

@implementation CardsViewController_iPhone

@synthesize tblCards = _tblCards;
@synthesize trash = _trash;
@synthesize action = _action;
@synthesize delegate = _delegate;
@synthesize activeCard = _activeCard;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil showUnauthorizedCards:(BOOL)bShowUnAuthorizedCards withFormType:(CardsViewFormType)formType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Cards_Title", @"Cards_Title");
        if (formType == CardsViewFormTypeSelectView)
            self.navigationItem.title = NSLocalizedString(@"Cards_SelectTitle", @"Cards_SelectTitle");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCard:)];
        _showUnAuthorizedCards = bShowUnAuthorizedCards;
        _cardsOCEAN = nil;
        _cardsVIRTUAL = nil;
        _cardsOTHER = nil;
        _cardsUnAuthorized = nil;
        _cards = nil;
        _activeCard = nil;
        _formType = formType;
        _activities = [NSArray arrayWithObjects:[[CardRefreshBalanceActivity alloc] initWithResultDelegate:self], [[CardReceiveMoneyActivity alloc] initWithResultDelegate:self], [[CardMoneySendActivity alloc] initWithResultDelegate:self], [[CardRequestSupportActivity alloc] initWithResultDelegate:self], [[CardCallSupportActivity alloc] initWithResultDelegate:self], [[CardAuthorizeActivity alloc] initWithResultDelegate:self], nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    switch (_formType) {
        case CardsViewFormTypeFullView: {
            self.tblCards.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 16, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 16 - 44);
            [self.view addSubview:self.tblCards.view];
            SWRevealViewController *revealViewController = [self revealViewController];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
            break;
        }
        case CardsViewFormTypeSelectView: {
            self.tblCards.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 16, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 16);
            [self.view addSubview:self.tblCards.view];
            break;
        }
        default:
            break;
    }
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getCards:) forControlEvents:UIControlEventValueChanged];
    [self.tblCards setRefreshControl:refreshControl];
    [self.tblCards.refreshControl beginRefreshing];
    [self performSelector:@selector(getCards:) withObject:nil afterDelay:.1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [self.tblCards.tableView indexPathForSelectedRow];
    self.trash.enabled = indexPath != nil;
    self.action.enabled = indexPath != nil;
}

- (void)getCards:(id)sender
{
    if (!self.tblCards.refreshControl.refreshing)
        [self.tblCards.refreshControl beginRefreshing];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetCards:self action:@selector(getCardsHandler:) UNIQUE:[app.userProfile uid] Hash:@"" NotIncludeRemoved:YES NotIncludeNotAuthorized:!_showUnAuthorizedCards];
}

- (void)getCardsHandler:(id)response
{
    [self.tblCards.refreshControl endRefreshing];

    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.cards && resp.cards != nil && [resp.cards count] > 0)
            {
                _cardsOCEAN = nil;
                _cardsVIRTUAL = nil;
                _cardsOTHER = nil;
                _cardsUnAuthorized = nil;
                _cards = nil;
                for (svcCard *card in resp.cards)
                {
                    if (!card.card_Removed)
                    {
                        if (!card.card_Approved)
                        {
                            if (_cardsUnAuthorized == nil)
                                _cardsUnAuthorized = [NSMutableArray arrayWithCapacity:0];
                            [_cardsUnAuthorized addObject:card];
                        }
                        else
                        {
                            if (card.card_IsOCEAN)
                            {
                                if ([card.card_Number hasPrefix:@"530554"] && [card.card_Name hasSuffix:@"OCEAN Virtual"])
                                {
                                    if (_cardsVIRTUAL == nil)
                                        _cardsVIRTUAL = [NSMutableArray arrayWithCapacity:0];
                                    [_cardsVIRTUAL addObject:card];
                                }
                                else
                                {
                                    if (_cardsOCEAN == nil)
                                        _cardsOCEAN = [NSMutableArray arrayWithCapacity:0];
                                    [_cardsOCEAN addObject:card];
                                }
                            }
                            else
                            {
                                if (_cardsOTHER == nil)
                                    _cardsOTHER = [NSMutableArray arrayWithCapacity:0];
                                [_cardsOTHER addObject:card];
                            }
                        }
                    }
                }
                _cards = [NSMutableArray arrayWithCapacity:0];
                if (_cardsOCEAN != nil)
                    [_cards addObject:_cardsOCEAN];
                if (_cardsVIRTUAL != nil)
                    [_cards addObject:_cardsVIRTUAL];
                if (_cardsOTHER != nil)
                    [_cards addObject:_cardsOTHER];
                if (_cardsUnAuthorized != nil)
                    [_cards addObject:_cardsUnAuthorized];
                [self.tblCards.tableView reloadData];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)cardsArrayForSection:(NSInteger)section
{
    if (_cards != nil)
        return [_cards objectAtIndex:section];
    else
        return nil;
}

- (NSInteger)cardsSectionCount
{
    if (_cards != nil)
        return [_cards count];
    else
        return 0;
}

- (NSInteger)cardsRowCountInSection:(NSInteger)section
{
    NSMutableArray *a = [self cardsArrayForSection:section];
    if (a && a != nil)
        return [a count];
    else
        return 0;
}

- (IBAction)addCard:(id)sender
{
    AddCardViewController_iPhone *addCardViewController = [[AddCardViewController_iPhone alloc] initWithNibName:@"AddCardViewController_iPhone" bundle:nil];
    addCardViewController.delegate = self;
    [self.navigationController pushViewController:addCardViewController animated:YES];
}

- (IBAction)removeCard:(id)sender
{
    NSIndexPath *indexPath = [self.tblCards.tableView indexPathForSelectedRow];
    NSArray *a = [self cardsArrayForSection:indexPath.section];
    svcCard *card = (svcCard *)[a objectAtIndex:indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RemoveCard_Title", @"RemoveCard_Title") message:[NSString stringWithFormat:NSLocalizedString(@"RemoveCard_Text", @"RemoveCard_Text"), card.card_Number] delegate:self cancelButtonTitle:NSLocalizedString(@"Button_No", @"Button_No") otherButtonTitles:NSLocalizedString(@"Button_Yes", @"Button_Yes"), nil];
    [alert show];
}

- (void)doRemoveCard
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    NSIndexPath *indexPath = [self.tblCards.tableView indexPathForSelectedRow];
    NSArray *a = [self cardsArrayForSection:indexPath.section];
    svcCard *card = (svcCard *)[a objectAtIndex:indexPath.row];
    [svc RemoveCard:self action:@selector(removeCardHandle:) UNIQUE:[app.userProfile uid] cardId:card.card_Id];
}

- (void)removeCardHandle:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            [self.tblCards.refreshControl beginRefreshing];
            [self performSelector:@selector(getCards:) withObject:nil afterDelay:.1];
            return;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RemoveCardFail_Title", @"RemoveCardFail_Title") message:NSLocalizedString(@"RemoveCardFail_Message", @"RemoveCardFail_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
}

- (IBAction)cardAction:(id)sender
{
    if (_selectedIndexPath == nil) return;
    NSArray *a = [self cardsArrayForSection:_selectedIndexPath.section];
    svcCard *c = (svcCard *)[a objectAtIndex:_selectedIndexPath.row];

    ActivityAction *action = [ActivityAction alloc];
    action.target = self;
    action.selector = @selector(getCards:);
    NSMutableArray *cc = [NSMutableArray arrayWithArray:_cardsOCEAN];
    [cc addObjectsFromArray:_cardsVIRTUAL];
    [cc addObjectsFromArray:_cardsOTHER];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:c, self.tblCards, action, cc, nil] applicationActivities:_activities];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self cardsSectionCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *a = [self cardsArrayForSection:section];
    if (a == _cardsOCEAN)
        return NSLocalizedString(@"Cards_TableSection_OCEAN_Header", @"Cards_TableSection_OCEAN_Header");
    if (a == _cardsVIRTUAL)
        return NSLocalizedString(@"Cards_TableSection_VIRTUAL_Header", @"Cards_TableSection_VIRTUAL_Header");
    if (a == _cardsOTHER)
        return NSLocalizedString(@"Cards_TableSection_OTHER_Header", @"Cards_TableSection_OTHER_Header");
    return NSLocalizedString(@"Cards_TableSection_NOTAUTHORIZED_Header", @"Cards_TableSection_NOTAUTHORIZED_Header");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self cardsRowCountInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndexPath && [_selectedIndexPath compare:indexPath] == NSOrderedSame && _formType == CardsViewFormTypeFullView)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SelectedCardCellView_iPhone" owner:self options:nil];
        SelectedCardCellView_iPhone *cell = (SelectedCardCellView_iPhone *)[nib objectAtIndex:0];
        
        ActivityAction *action = [ActivityAction alloc];
        action.target = self;
        action.selector = @selector(getCards:);
        NSMutableArray *cc = [NSMutableArray arrayWithArray:_cardsOCEAN];
        [cc addObjectsFromArray:_cardsVIRTUAL];
        [cc addObjectsFromArray:_cardsOTHER];
        svcCard *c = (svcCard *)[[self cardsArrayForSection:indexPath.section] objectAtIndex:indexPath.row];
        
        [cell applyCard:[NSArray arrayWithObjects:c, self.tblCards, action, cc, nil] withActivities:_activities];
        
        
        if (self.activeCard != nil && c.card_Id == self.activeCard.card_Id)
        {
            [cell startActive];
        }
        else
        {
            [cell stopActive];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CardCellView_iPhone" owner:self options:nil];
        CardCellView_iPhone *cell = (CardCellView_iPhone *)[nib objectAtIndex:0];
    
        svcCard *crd = (svcCard *)[[self cardsArrayForSection:indexPath.section] objectAtIndex:indexPath.row];
        [cell applyCard:crd];
    
        if (self.activeCard != nil && crd.card_Id == self.activeCard.card_Id)
        {
            [cell startActive];
        }
        else
        {
            [cell stopActive];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;

        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *ip = _selectedIndexPath;
    _selectedIndexPath = indexPath;
    
    if (_formType == CardsViewFormTypeSelectView)
    {
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(cardSelected:controller:)])
        {
            NSArray *a = [self cardsArrayForSection:indexPath.section];
            [self.delegate cardSelected:(svcCard *)[a objectAtIndex:indexPath.row] controller:self];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    else
    {
        if ([_selectedIndexPath compare:ip] == NSOrderedSame)
        {
            self.trash.enabled = NO;
            self.action.enabled = NO;
            _selectedIndexPath = nil;
            [tableView beginUpdates];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:ip, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        }
        else
        {
            self.trash.enabled = YES;
            self.action.enabled = YES;
            [tableView beginUpdates];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:_selectedIndexPath, ip, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndexPath && [_selectedIndexPath compare:indexPath] == NSOrderedSame && _formType == CardsViewFormTypeFullView)
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
    self.trash.enabled = NO;
    self.action.enabled = NO;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app showWait:NSLocalizedString(@"CardRemove_Wait_Message", @"CardRemove_Wait_Message")];
        [self performSelector:@selector(doRemoveCard) withObject:nil afterDelay:.1];
    }
}

#pragma mark AddCardViewControllerDelegate

- (void)addCardFinished:(UIViewController *)controller withResult:(BOOL)result
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tblCards.refreshControl beginRefreshing];
    [self performSelector:@selector(getCards:) withObject:nil afterDelay:.1];
}

#pragma mark ActivityResultDelegate

- (void)activityStart:(id)obj
{
    svcCard *card = (svcCard *)obj;
    self.activeCard = card;
    [self.tblCards.tableView reloadData];
}

- (void)activityEnd:(id)obj
{
    svcCard *card = (svcCard *)obj;
    self.activeCard = nil;
    [self.tblCards.tableView reloadData];
}

@end
