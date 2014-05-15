//
//  PayCharityViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 15.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "PayCharityViewController_iPhone.h"

@interface PayCharityViewController_iPhone ()

@end

@implementation PayCharityViewController_iPhone

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withCharity:(svcCharity *)charity
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _charity = charity;
        self.navigationItem.title = NSLocalizedString(@"PayCharity_Title", @"PayCharity_Title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
