//
//  AcceptOfertaViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 28.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "AcceptOfertaViewController_iPhone.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"

@interface AcceptOfertaViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UIScrollView *svBack;
@property (nonatomic, retain) IBOutlet UILabel *lblOferta;
@property (nonatomic, retain) IBOutlet UIButton *btnContinue;

- (IBAction)btnContinue_Click:(id)sender;

@end

@implementation AcceptOfertaViewController_iPhone

@synthesize svBack = _svBack;
@synthesize lblOferta = _lblOferta;
@synthesize btnContinue = _btnContinue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Register_AcceptOferta_Title", @"Register_AcceptOferta_Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL* filePath = [[NSBundle mainBundle] URLForResource:NSLocalizedString(@"Register_OfertaText", @"Register_OfertaText") withExtension:@"rtf"];
    self.lblOferta.attributedText = [[NSAttributedString alloc] initWithFileURL:filePath options:nil documentAttributes:nil error:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    CGRect expectedLabelSize = [self.lblOferta.attributedText boundingRectWithSize:(CGSize){300, CGFLOAT_MAX} options: NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGRect newFrame = self.lblOferta.frame;
    newFrame.size.height = expectedLabelSize.size.height;
    newFrame.origin.x = 10;
    newFrame.size.width -= 20;
    self.lblOferta.frame = newFrame;
    [self.svBack addSubview:self.lblOferta];
    self.btnContinue.frame = CGRectMake(20, self.lblOferta.frame.size.height + self.btnContinue.frame.size.height, self.btnContinue.frame.size.width, self.btnContinue.frame.size.height);
    [self.svBack addSubview:self.btnContinue];
    self.svBack.scrollEnabled = YES;
    self.svBack.frame = self.view.frame;
    self.svBack.contentSize = CGSizeMake(self.view.frame.size.width, newFrame.size.height + self.btnContinue.frame.size.height * 3);
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app personVoiceForGroup:@"Registration" andAction:@"Oferta"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnContinue_Click:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Register_AcceptOferta_Title", @"Register_AcceptOferta_Title") message:NSLocalizedString(@"Register_AcceptOferta_AcceptText", @"Register_AcceptOferta_AcceptText") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_No", @"Button_No") otherButtonTitles:NSLocalizedString(@"Button_Yes", @"Button_Yes"), nil];
    [alert show];
}

- (void)registerProfile
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc SaveSettings:self action:@selector(saveSettingsHandler:) UNIQUE:[app.userProfile uid] Phone:[app.userProfile phone] EMail:[app.userProfile email]];
}

- (void)saveSettingsHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            svcWSMobileBANK *svc = [svcWSMobileBANK service];
            svc.logging = YES;
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [svc SetPassword:self action:@selector(setPasswordHandler:) UNIQUE:[app.userProfile uid] Password:[app.userProfile password]];
        }
        else
        {
            [self showSaveError];
        }
        return;
    }
    [self showSaveError];
}

- (void)setPasswordHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app.userProfile saveChanges];
            [app.userProfile storeToCloud];
            app.userProfile.ofertaAccepted = YES;
            [app varSet:@"OfertaAccepted" value:@"YES"];
            [app.userProfile storeUserDataToCloud];
            [app hideWait];
            [app performSelector:@selector(getScenario) withObject:nil afterDelay:.1];
        }
        else
        {
            [self showSaveError];
        }
        return;
    }
    [self showSaveError];
}

- (void)showSaveError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UserProfile_SaveSettings_ErrorTitle", @"UserProfile_SaveSettings_ErrorTitle") message:NSLocalizedString(@"UserProfile_SaveSettings_ErrorMessage", @"UserProfile_SaveSettings_ErrorMessage") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            [self.navigationItem setHidesBackButton:YES animated:YES];
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app showWait:NSLocalizedString(@"Register_StoreToServer_Waiting_Text", @"Register_StoreToServer_Waiting_Text")];
            [self performSelector:@selector(registerProfile) withObject:nil afterDelay:1];
            break;
        }
        default:
            break;
    }
}

@end
