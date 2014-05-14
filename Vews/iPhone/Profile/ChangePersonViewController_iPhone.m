//
//  ChangePersonViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 25.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "ChangePersonViewController_iPhone.h"

@interface ChangePersonViewController_iPhone ()

@end

@implementation ChangePersonViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"ChangePerson_Title", @"ChangePerson_Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
