//
//  EnterCVCViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 18.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "EnterCVCViewController_iPhone.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "LocalCard.h"

@interface EnterCVCViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextField *tfCVC;
@property (nonatomic) int cardId;
@property (nonatomic, retain) NSString *storedCVC;
@property (nonatomic, retain) AppSettings *settings;

@end

@implementation EnterCVCViewController_iPhone

@synthesize tfCVC = _tfCVC;
@synthesize delegate = _delegate;
@synthesize cardId = _cardId;
@synthesize settings = _settings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.settings = [[AppSettings alloc] init];
        [self.settings loadSettings];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withCard:(int)card_Id
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cardId = card_Id;
        self.settings = [[AppSettings alloc] init];
        [self.settings loadSettings];
        if (self.settings.storeCVC)
            [self loadStoredCVC];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tfCVC.text = self.storedCVC;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)applyCard:(int)card_Id
{
    self.cardId = card_Id;
    if (self.settings.storeCVC) {
        [self loadStoredCVC];
        self.tfCVC.text = self.storedCVC;
    }
}

- (void)loadStoredCVC
{
    self.storedCVC = @"";
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocalCard"];
    request.predicate = [NSPredicate predicateWithFormat:@"card_Id == %i", self.cardId];
    NSArray *result = [app.managedObjectContext executeFetchRequest:request error:&error];
    if (result && [result count] > 0)
    {
        LocalCard *localCard = (LocalCard *)[result objectAtIndex:0];
        
        if (localCard)
        {
            self.storedCVC = localCard.cvc;
        }
    }
}

- (void)storeCVC
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocalCard"];
    request.predicate = [NSPredicate predicateWithFormat:@"card_Id == %i", self.cardId];
    NSArray *result = [app.managedObjectContext executeFetchRequest:request error:&error];
    if (result && [result count] > 0)
    {
        LocalCard *localCard = (LocalCard *)[result objectAtIndex:0];
        
        if (localCard)
        {
            localCard.cvc = self.tfCVC.text;
            [app saveContext];
            return;
        }
    }
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LocalCard" inManagedObjectContext:app.managedObjectContext];
    LocalCard *local = [[LocalCard alloc] initWithEntity:entity insertIntoManagedObjectContext:app.managedObjectContext];
    local.card_Id = [NSNumber numberWithInt:self.cardId];
    local.cvc = self.tfCVC.text;
    [app saveContext];
}

- (void)setNeverStore
{
    [self.settings setStoreCVCToNO];
}

- (void)addToViewController:(UIViewController *)controller
{
    self.view.frame = CGRectMake(0, controller.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [controller.view addSubview:self.view];
    [controller.view bringSubviewToFront:self.view];

    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.view.frame = CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self.tfCVC becomeFirstResponder];
                     }];
}

- (void)removeFromViewController
{
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.view.frame = CGRectMake(0, self.view.superview.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                     }];
}

- (IBAction)doneButton:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([self.tfCVC.text isEqualToString:self.storedCVC] || !self.settings.storeCVC || app.userProfile.isDemoMode || [self.tfCVC.text isEqualToString:@""]) {
        [self.tfCVC resignFirstResponder];
        [self.delegate finishEnterCVC:self cvcEntered:YES cvcValue:self.tfCVC.text];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StoreCVC_Title", @"StoreCVC_Title") message:NSLocalizedString(@"StoreCVC_Message", @"StoreCVC_Message") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_NeverStoreCVC", @"Button_NeverStoreCVC") otherButtonTitles:NSLocalizedString(@"Button_Continue", @"Button_Continue"), NSLocalizedString(@"Button_No", @"Button_No"), nil];
        [alert show];
    }
}

- (IBAction)cancelButton:(id)sender
{
    [self.tfCVC resignFirstResponder];
    [self.delegate cancelEnterCVC:self];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            //Никогда более не спрашивать
            [self setNeverStore];
            [self.tfCVC resignFirstResponder];
            [self.delegate finishEnterCVC:self cvcEntered:YES cvcValue:self.tfCVC.text];
            break;
        }
        case 1: {
            //Да
            [self storeCVC];
            [self.tfCVC resignFirstResponder];
            [self.delegate finishEnterCVC:self cvcEntered:YES cvcValue:self.tfCVC.text];
            break;
        }
        case 2: {
            //Нет
            [self.tfCVC resignFirstResponder];
            [self.delegate finishEnterCVC:self cvcEntered:YES cvcValue:self.tfCVC.text];
            break;
        }
        default: {
            [self.tfCVC resignFirstResponder];
            [self.delegate finishEnterCVC:self cvcEntered:YES cvcValue:self.tfCVC.text];
            break;
        }
    }
}

@end
