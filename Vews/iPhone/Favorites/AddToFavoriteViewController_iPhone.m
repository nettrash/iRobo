//
//  AddToFavoriteViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 04.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "AddToFavoriteViewController_iPhone.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"

@interface AddToFavoriteViewController_iPhone ()

@property (nonatomic, retain) svcHistoryOperation *operation;
@property (nonatomic, retain) IBOutlet UITableViewController *tblFavorite;
@property (nonatomic) int favoriteId;
@property (nonatomic, retain) NSString *favoriteName;
@property (nonatomic, retain) NSDecimalNumber *summa;
@property (nonatomic, retain) UITextField *tfName;
@property (nonatomic, retain) UITextField *tfSumma;

@end

@implementation AddToFavoriteViewController_iPhone

@synthesize delegate = _delegate;
@synthesize operation = _operation;
@synthesize tblFavorite = _tblFavorite;
@synthesize favoriteId = _favoriteId;
@synthesize favoriteName = _favoriteName;
@synthesize summa = _summa;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withOperation:(svcHistoryOperation *)op
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.favoriteId = -1;
        self.favoriteName = op.currName;
        self.summa = op.op_Sum;
        self.operation = op;
        self.navigationItem.title = NSLocalizedString(@"AddToFavorite_Title", @"AddToFavorite_Title");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addToFavorite:)];
        
        self.tfName = [[UITextField alloc] initWithFrame:CGRectMake(15, 6, 285, 30)];
        self.tfName.adjustsFontSizeToFitWidth = YES;
        self.tfName.textColor = [UIColor darkGrayColor];
        self.tfName.keyboardType = UIKeyboardTypeDefault;
        self.tfName.autocapitalizationType = UITextAutocapitalizationTypeWords;
        //self.tfName.delegate = self;
        self.tfName.text = self.favoriteName;
        [self.tfName setTextAlignment:NSTextAlignmentRight];
        self.tfName.clearsOnBeginEditing = YES;

        self.tfSumma = [[UITextField alloc] initWithFrame:CGRectMake(15, 6, 285, 30)];
        self.tfSumma.adjustsFontSizeToFitWidth = YES;
        self.tfSumma.textColor = [UIColor darkGrayColor];
        self.tfSumma.keyboardType = UIKeyboardTypeDecimalPad;
        self.tfSumma.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
//        self.tfSumma.delegate = self;
        self.tfSumma.text = [self.summa stringValue];
        [self.tfSumma setTextAlignment:NSTextAlignmentRight];
        self.tfSumma.clearsOnBeginEditing = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tblFavorite.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 16, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 16);
    [self.view addSubview:self.tblFavorite.view];
    [self.tblFavorite.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)addToFavorite:(id)sender
{
    [self.tfName resignFirstResponder];
    [self.tfSumma resignFirstResponder];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"FavoriteAdd_Waiting", @"FavoriteAdd_Waiting")];
    
    self.favoriteName = self.tfName.text;
    self.summa = [NSDecimalNumber decimalNumberWithString:[self.tfSumma.text stringByReplacingOccurrencesOfString:@"," withString:@"."]];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    
    [svc AddFavorite:self action:@selector(addFavoriteHandler:) UNIQUE:[app.userProfile uid] favoriteId:self.favoriteId favoriteName:self.favoriteName currency:self.operation.out_curr currencyName:self.operation.currName cardId:0 parameters:self.operation.op_Parameters summa:self.summa];
}

- (void)addFavoriteHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            [self.delegate addToFavorite:self operation:self.operation withName:self.favoriteName andSumm:self.summa];
            return;
        }
    }
    //Ошибка удаления
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AddToFavorite_Title", @"AddToFavorite_Title") message:NSLocalizedString(@"AddToFavorite_ErrorMessage", @"AddToFavorite_ErrorMessage") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
}

#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"AddFavorite_TableGroup_Title_Name", @"AddFavorite_TableGroup_Title_Name");
        case 1:
            return NSLocalizedString(@"AddFavorite_TableGroup_Title_Summa", @"AddFavorite_TableGroup_Title_Summa");
        default:
            return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteNameCell"];
            BOOL dequeued = YES;
            if (cell == nil) {
                dequeued = NO;
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FavoriteNameCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            if (!dequeued)
            {
                [cell addSubview:self.tfName];
            }

            return cell;
        }
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteSummaCell"];
            BOOL dequeued = YES;
            if (cell == nil) {
                dequeued = NO;
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FavoriteSummaCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if (!dequeued)
            {
                [cell addSubview:self.tfSumma];
            }
            
            return cell;
        }
        default:
            return nil;
    }
    
    return nil;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
