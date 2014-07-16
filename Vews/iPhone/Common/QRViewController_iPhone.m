//
//  QRViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 14.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "QRViewController_iPhone.h"
#import "UIImage+QR.h"

@interface QRViewController_iPhone ()

@property (nonatomic, retain) UIImage *qrImage;
@property (nonatomic, retain) IBOutlet UIImageView *imgQR;
@property (nonatomic, retain) IBOutlet UILabel *lblInfo;

@end

@implementation QRViewController_iPhone

@synthesize qrImage = _qrImage;
@synthesize imgQR = _imgQR;
@synthesize lblInfo = _lblInfo;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withSource:(NSString *)source andWidth:(int)width
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"QR_Title", @"QR_Title");
        self.qrImage = [UIImage quickResponseImageForString:source withDimension:width];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(saveToPhoto:)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgQR.image = self.qrImage;
    self.lblInfo.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)saveToPhoto:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(self.imgQR.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QR_Title", @"QR_Title") message:NSLocalizedString(@"StoreQR_Error", @"StoreQR_Error") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    else
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"QR_Title", @"QR_Title") message:NSLocalizedString(@"StoreQR_Success", @"StoreQR_Success") delegate:self cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    
    [alert show];
}

- (IBAction)btnInfo_Click:(id)sender
{
    self.lblInfo.hidden = !self.lblInfo.hidden;
}

@end
