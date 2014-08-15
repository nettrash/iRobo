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
@property (nonatomic, strong) UIImageView *imgBlank;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *aiWait;
@property (nonatomic, retain) IBOutlet UILabel *lblInfo;
@property (nonatomic, retain) IBOutlet UIScrollView *svImage;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end

@implementation BlankViewController_iPhone

@synthesize delegate = _delegate;
@synthesize operation = _operation;
@synthesize imgBlank = _imgBlank;
@synthesize aiWait = _aiWait;
@synthesize lblInfo = _lblInfo;
@synthesize svImage = _svImage;

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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)getBlank:(id)sender
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://misc.roboxchange.com/External/iPhone/blank.ashx?OpKey=%@", self.operation.op_Key]]];
    UIImage *blankImage = [UIImage imageWithData:data];
    if (blankImage == nil)
    {
        self.lblInfo.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else
    {
        self.lblInfo.hidden = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(saveToPhoto:)];

        self.imgBlank = [[UIImageView alloc] initWithImage:blankImage];
        self.imgBlank.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=blankImage.size};
        [self.imgBlank setContentMode:UIViewContentModeTopLeft];
        [self.svImage addSubview:self.imgBlank];
        
        self.svImage.contentSize = blankImage.size;
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        [self.svImage addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
        twoFingerTapRecognizer.numberOfTapsRequired = 1;
        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
        [self.svImage addGestureRecognizer:twoFingerTapRecognizer];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPinchDetected:)];
        [self.svImage addGestureRecognizer:pinchRecognizer];
    
        CGRect scrollViewFrame = self.svImage.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / self.svImage.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.svImage.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        self.svImage.minimumZoomScale = minScale;
        
        self.svImage.maximumZoomScale = 3.0f;
        self.svImage.zoomScale = minScale;
        
        [self centerScrollViewContents];
    }
    [self.aiWait stopAnimating];
}

- (void)centerScrollViewContents
{
    //Центровать не надо
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    CGPoint pointInView = [recognizer locationInView:self.imgBlank];
    
    CGFloat newZoomScale = self.svImage.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.svImage.maximumZoomScale);
    
    CGSize scrollViewSize = self.svImage.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.svImage zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer
{
    CGFloat newZoomScale = self.svImage.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.svImage.minimumZoomScale);
    [self.svImage setZoomScale:newZoomScale animated:YES];
}

- (void)scrollViewPinchDetected:(UIPinchGestureRecognizer *)recognizer
{
    [self.svImage setZoomScale:[recognizer scale] animated:YES];
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

#pragma marj UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgBlank;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

@end
