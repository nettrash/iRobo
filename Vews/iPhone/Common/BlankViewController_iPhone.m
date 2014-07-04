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
@property (nonatomic, retain) IBOutlet UIImageView *imgBlank;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *aiWait;
@property (nonatomic, retain) IBOutlet UILabel *lblInfo;

@end

@implementation BlankViewController_iPhone

@synthesize delegate = _delegate;
@synthesize operation = _operation;
@synthesize imgBlank = _imgBlank;
@synthesize aiWait = _aiWait;
@synthesize lblInfo = _lblInfo;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withOperation:(svcHistoryOperation *)op
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.operation = op;
        self.navigationItem.title = NSLocalizedString(@"Blank_Title", @"Blank_Title");
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
    [self performSelector:@selector(getBlank:) withObject:nil afterDelay:.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)getBlank:(id)sender
{
    self.imgBlank.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://misc.roboxchange.com/External/iPhone/blank.ashx?OpKey=%@", self.operation.op_Key]]]];
    if (self.imgBlank.image == nil)
    {
        self.lblInfo.text = [NSString stringWithFormat:@"https://misc.roboxchange.com/External/iPhone/blank.ashx?OpKey=%@", self.operation.op_Key];
    }
    else
    {
        self.lblInfo.hidden = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(saveToPhoto:)];
    }
    [self.aiWait stopAnimating];
}

- (void)saveToPhoto:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(self.imgBlank.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StoreBlank_Title", @"StoreBlank_Title") message:NSLocalizedString(@"StoreBlank_Error", @"StoreBlank_Error") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    else
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StoreBlank_Title", @"StoreBlank_Title") message:NSLocalizedString(@"StoreBlank_Success", @"StoreBlank_Success") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    
    [alert show];
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
