//
//  ScanViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 14.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "ScanViewController_iPhone.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ScanViewController_iPhone ()

@property (nonatomic, retain) id<ScanViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton *btnCancel;
@property (nonatomic, retain) IBOutlet UIButton *btnInfo;
@property (nonatomic, retain) IBOutlet UIButton *btnTorch;
@property (nonatomic, retain) IBOutlet UITextView *lblInfoText;

@property (nonatomic, retain) AVCaptureDevice *device;
@property (nonatomic, retain) AVCaptureDeviceInput *input;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureMetadataOutput *output;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *preview;

@end

@implementation ScanViewController_iPhone

@synthesize delegate = _delegate;
@synthesize btnCancel = _btnCancel;
@synthesize btnInfo = _btnInfo;
@synthesize btnTorch = _btnTorch;
@synthesize lblInfoText = _lblInfoText;

@synthesize device = _device;
@synthesize input = _input;
@synthesize session = _session;
@synthesize output = _output;
@synthesize preview = _preview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<ScanViewControllerDelegate>)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblInfoText.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupScanner];
    [self startScanning];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    AVCaptureConnection *con = self.preview.connection;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeRight:
            con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationPortrait:
            con.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            con.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnClose_Click:(id)sender
{
    [self stopScanning];
    [self.delegate scanResult:self success:NO result:nil];
}

- (IBAction)btnInfo_Click:(id)sender
{
    self.lblInfoText.hidden = !self.lblInfoText.hidden;
}

- (IBAction)btnTorch_Click:(id)sender
{
    [self.device lockForConfiguration:nil];
    if (self.device.torchMode == AVCaptureTorchModeOff)
        [self.device setTorchMode:AVCaptureTorchModeOn];
    else
        [self.device setTorchMode:AVCaptureTorchModeOff];
    [self.device unlockForConfiguration];
}

#pragma mark Scanner methods

- (void)setupScanner
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    self.session = [[AVCaptureSession alloc] init];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                                        AVMetadataObjectTypeCode39Code,
                                        AVMetadataObjectTypeCode39Mod43Code,
                                        AVMetadataObjectTypeEAN13Code,
                                        AVMetadataObjectTypeEAN8Code,
                                        AVMetadataObjectTypeCode93Code,
                                        AVMetadataObjectTypeCode128Code,
                                        AVMetadataObjectTypePDF417Code,
                                        AVMetadataObjectTypeQRCode,
                                        AVMetadataObjectTypeAztecCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    AVCaptureConnection *con = self.preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [self.view bringSubviewToFront:self.btnCancel];
    [self.view bringSubviewToFront:self.btnInfo];
    [self.view bringSubviewToFront:self.btnTorch];
    [self.view bringSubviewToFront:self.lblInfoText];
    
    self.btnTorch.hidden = !self.device.torchAvailable;
}

- (void)startScanning
{
    [self.session startRunning];
}

- (void)stopScanning
{
    [self.session stopRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            [self stopScanning];
            AudioServicesPlayAlertSound(1000);
            [self.delegate scanResult:self success:YES result:(AVMetadataMachineReadableCodeObject *)current];
        }
    }
}

@end
