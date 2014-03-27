//
//  RegisterViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 27.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "RegisterViewController_iPhone.h"

@interface RegisterViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UITextView *tvIntro;

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
    NSError *err = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:NSLocalizedString(@"Register_IntroText", @"Register_IntroText") encoding:NSUTF8StringEncoding error:&err];
    if (fileContents == nil) {
        NSLog(@"Register Text Error reading %@: %@", NSLocalizedString(@"Register_IntroText", @"Register_IntroText"), err);
    } else {
        self.tvIntro.text = fileContents;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
