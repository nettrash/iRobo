//
//  ComissionViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 04.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "ComissionViewController_iPhone.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "NSNumber+Currency.h"

@interface ComissionViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UIImageView *imgBack;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *aivWait;
@property (nonatomic, retain) IBOutlet UILabel *lblComission;
@property (nonatomic, retain) IBOutlet UIButton *btnAccept;
@property (nonatomic, retain) IBOutlet UIButton *btnDecline;

@end

@implementation ComissionViewController_iPhone

@synthesize imgBack = _imgBack;
@synthesize aivWait = _aivWait;
@synthesize lblComission = _lblComission;
@synthesize delegate = _delegate;
@synthesize btnAccept = _btnAccept;
@synthesize btnDecline = _btnDecline;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currency:(NSString*)curr OutSumma:(NSDecimalNumber *)summ cardId:(int)card_Id
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currency = curr;
        _summa = summ;
        _card_Id = card_Id;
        _backImageName = @"Comission.png";
        _isInc = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currency:(NSString*)curr OutSumma:(NSDecimalNumber *)summ cardId:(int)card_Id andBackground:(NSString *)backImageName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currency = curr;
        _summa = summ;
        _card_Id = card_Id;
        _backImageName = backImageName;
        _isInc = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currency:(NSString*)curr IncSumma:(NSDecimalNumber *)summ cardId:(int)card_Id
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currency = curr;
        _summa = summ;
        _card_Id = card_Id;
        _backImageName = @"Comission.png";
        _isInc = YES;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currency:(NSString*)curr IncSumma:(NSDecimalNumber *)summ cardId:(int)card_Id andBackground:(NSString *)backImageName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currency = curr;
        _summa = summ;
        _card_Id = card_Id;
        _backImageName = backImageName;
        _isInc = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblComission.hidden = YES;
    self.btnAccept.enabled = NO;
    self.btnDecline.enabled = NO;
    [self.aivWait startAnimating];
    self.imgBack.image = [UIImage imageNamed:_backImageName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSelector:@selector(calculateComission:) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)calculateComission:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc CalcSumWithCard:self action:@selector(calculateComissionHandler:) UNIQUE:[app.userProfile uid] currency:_currency IsInc:_isInc summ:_summa cardId:_card_Id];
}

- (void)calculateComissionHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            self.lblComission.hidden = NO;
            [self.aivWait stopAnimating];
            self.btnAccept.enabled = YES;
            self.btnDecline.enabled = YES;
            self.lblComission.text = [NSString stringWithFormat:@"+ %@", [[resp.Summa decimalNumberBySubtracting:_summa] numberWithCurrency]];
            return;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorCalcComission_Title", @"ErrorCalcComission_Title") message:NSLocalizedString(@"ErrorCalcComission_Message", @"ErrorCalcComission_Message") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_No", @"Button_No") otherButtonTitles:NSLocalizedString(@"Button_Yes", @"Button_Yes"), nil];
    [alert show];
}

- (IBAction)btnAccept_Click:(id)sender
{
    [self.delegate acceptingComissionFinished:self withResult:YES];
}

- (IBAction)btnDecline_Click:(id)sender
{
    [self.delegate acceptingComissionFinished:self withResult:NO];
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

#pragma mark UIAlertViewDleegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self calculateComission:nil];
    }
    else
    {
        [self btnDecline_Click:nil];
    }
}

@end
