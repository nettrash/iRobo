//
//  BlankViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 03.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "BlankViewController_iPhone.h"

@interface BlankViewController_iPhone ()

@property (nonatomic, retain) svcHistoryOperation *operation;

@end

@implementation BlankViewController_iPhone

@synthesize delegate = _delegate;
@synthesize operation = _operation;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withOperation:(svcHistoryOperation *)op
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.operation = op;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
