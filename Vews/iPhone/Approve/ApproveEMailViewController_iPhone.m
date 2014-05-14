//
//  ApproveEMailViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 08.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "ApproveEMailViewController_iPhone.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"

@interface ApproveEMailViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UILabel *lblEMail;

- (IBAction)btnCheckEMail_Click:(id)sender;

@end

@implementation ApproveEMailViewController_iPhone

@synthesize lblEMail = _lblEMail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"ApproveEMail_Title", @"ApproveEMail_Title");
        [self.navigationItem setHidesBackButton:YES animated:YES];
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
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.lblEMail.text = app.userProfile.email;
    [self performSelector:@selector(checkServerSettings) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)checkServerSettings
{
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [svc GetSettings:self action:@selector(getSettingsHandler:) UNIQUE:[app.userProfile uid] Platform:[app PlatformName] Device:[app DeviceName]];
}

- (void)getSettingsHandler:(id)response
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            if (wsResponse.settings.EMailApproved)
            {
                app.userProfile.emailApproved = YES;
                [app.userProfile storeToCloud];
                [app.userProfile saveChanges];
                [app performSelector:@selector(getScenario) withObject:nil afterDelay:.1];
                return;
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CheckEMail_Title", @"CheckEMail_Title") message:NSLocalizedString(@"CheckEMail_Message", @"CheckEMail_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
                [alert show];
                [self performSelector:@selector(checkEMail) withObject:nil afterDelay:.1];
                return;
            }
        }
    }
    [self showCheckSettingsError];
}

- (void)showCheckSettingsError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CheckSettingsError_Title", @"CheckSettingsError_Title") message:NSLocalizedString(@"CheckSettingsError_Message", @"CheckSettingsError_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_AnotherOne", @"Button_AnotherOne") otherButtonTitles:nil];
    [alert show];
}

- (void)checkEMail
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc CheckEMail:self action:@selector(checkEMailHandler:) UNIQUE:[app.userProfile uid]];
}

- (void)checkEMailHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            return;
        }
    }
    [self showCheckEMailError];
}

- (void)showCheckEMailError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CheckEMailError_Title", @"CheckEMailError_Title") message:NSLocalizedString(@"CheckEMailError_Message", @"CheckEmailError_Message") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_AnotherOne", @"Button_AnotherOne") otherButtonTitles:nil];
    [alert show];
}

- (IBAction)btnCheckEMail_Click:(id)sender
{
    [self checkServerSettings];
}

@end
