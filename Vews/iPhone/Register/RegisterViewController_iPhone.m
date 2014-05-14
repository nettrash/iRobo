//
//  RegisterViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 27.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "AppDelegate.h"
#import "RegisterViewController_iPhone.h"
#import "EnterPhoneViewController_iPhone.h"

@interface RegisterViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextView *tvIntro;

- (IBAction)btnContinue_Click:(id)sender;

@end

@implementation RegisterViewController_iPhone

@synthesize tvIntro = _tvIntro;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.navigationItem.title = NSLocalizedString(@"Register_Title", @"Register_Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL* filePath = [[NSBundle mainBundle] URLForResource:NSLocalizedString(@"Register_IntroText", @"Register_IntroText") withExtension:@"rtf"];
    self.tvIntro.attributedText = [[NSAttributedString alloc] initWithFileURL:filePath options:nil documentAttributes:nil error:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app personVoiceForGroup:@"Registration" andAction:@"Intro"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnContinue_Click:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app stopSound];
    [self.navigationController pushViewController:[[EnterPhoneViewController_iPhone alloc] initWithNibName:@"EnterPhoneViewController_iPhone" bundle:nil] animated:YES];
}

@end
