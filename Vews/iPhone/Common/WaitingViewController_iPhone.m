//
//  WaitingViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 28.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "WaitingViewController_iPhone.h"

@interface WaitingViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UIImageView *imgWait1;
@property (nonatomic, retain) IBOutlet UIImageView *imgWait2;
@property (nonatomic, retain) IBOutlet UIImageView *imgWait3;
@property (nonatomic, retain) IBOutlet UIImageView *imgWait4;
@property (nonatomic, retain) IBOutlet UIImageView *imgWait5;
@property (nonatomic, retain) IBOutlet UIImageView *imgWait6;
@property (nonatomic, retain) IBOutlet UIImageView *imgWait7;
@property (nonatomic, retain) IBOutlet UIImageView *imgWait8;

@property (nonatomic, retain) IBOutlet UILabel *lblMessage;

@end

@implementation WaitingViewController_iPhone

@synthesize imgWait1 = _imgWait1;
@synthesize imgWait2 = _imgWait2;
@synthesize imgWait3 = _imgWait3;
@synthesize imgWait4 = _imgWait4;
@synthesize imgWait5 = _imgWait5;
@synthesize imgWait6 = _imgWait6;
@synthesize imgWait7 = _imgWait7;
@synthesize imgWait8 = _imgWait8;
@synthesize lblMessage = _lblMessage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _animate = NO;
        _animateCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Animation

- (void)setWaitImagesToBig {
    self.imgWait1.frame = CGRectMake(61, 352, 24, 24);
    self.imgWait2.frame = CGRectMake(86, 352, 24, 24);
    self.imgWait3.frame = CGRectMake(111, 352, 24, 24);
    self.imgWait4.frame = CGRectMake(136, 352, 24, 24);
    self.imgWait5.frame = CGRectMake(161, 352, 24, 24);
    self.imgWait6.frame = CGRectMake(186, 352, 24, 24);
    self.imgWait7.frame = CGRectMake(211, 352, 24, 24);
    self.imgWait8.frame = CGRectMake(236, 352, 24, 24);
}

- (void)setWaitImagesToSmall {
    self.imgWait1.frame = CGRectMake(64, 355, 18, 18);
    self.imgWait2.frame = CGRectMake(89, 355, 18, 18);
    self.imgWait3.frame = CGRectMake(114, 355, 18, 18);
    self.imgWait4.frame = CGRectMake(139, 355, 18, 18);
    self.imgWait5.frame = CGRectMake(164, 355, 18, 18);
    self.imgWait6.frame = CGRectMake(189, 355, 18, 18);
    self.imgWait7.frame = CGRectMake(214, 355, 18, 18);
    self.imgWait8.frame = CGRectMake(239, 355, 18, 18);
}

- (void)setWaitImageToSmall : (UIImageView *) img {
    if (img == self.imgWait1)
        self.imgWait1.frame = CGRectMake(64, 355, 18, 18);
    if (img == self.imgWait2)
        self.imgWait2.frame = CGRectMake(89, 355, 18, 18);
    if (img == self.imgWait3)
        self.imgWait3.frame = CGRectMake(114, 355, 18, 18);
    if (img == self.imgWait4)
        self.imgWait4.frame = CGRectMake(139, 355, 18, 18);
    if (img == self.imgWait5)
        self.imgWait5.frame = CGRectMake(164, 355, 18, 18);
    if (img == self.imgWait6)
        self.imgWait6.frame = CGRectMake(189, 355, 18, 18);
    if (img == self.imgWait7)
        self.imgWait7.frame = CGRectMake(214, 355, 18, 18);
    if (img == self.imgWait8)
        self.imgWait8.frame = CGRectMake(239, 355, 18, 18);
}

- (void)setWaitImageToBig : (UIImageView *) img {
    if (img == self.imgWait1)
        self.imgWait1.frame = CGRectMake(61, 352, 24, 24);
    if (img == self.imgWait2)
        self.imgWait2.frame = CGRectMake(86, 352, 24, 24);
    if (img == self.imgWait3)
        self.imgWait3.frame = CGRectMake(111, 352, 24, 24);
    if (img == self.imgWait4)
        self.imgWait4.frame = CGRectMake(136, 352, 24, 24);
    if (img == self.imgWait5)
        self.imgWait5.frame = CGRectMake(161, 352, 24, 24);
    if (img == self.imgWait6)
        self.imgWait6.frame = CGRectMake(186, 352, 24, 24);
    if (img == self.imgWait7)
        self.imgWait7.frame = CGRectMake(211, 352, 24, 24);
    if (img == self.imgWait8)
        self.imgWait8.frame = CGRectMake(236, 352, 24, 24);
}

- (void)startAnimation:(NSString *)message
{
    self.lblMessage.text = message;
    [self setWaitImagesToSmall];
    [self startWaitingAnimation];
}

- (void)stopAnimation
{
    _animate = NO;
}

- (void)startWaitingAnimation
{
    _animate = YES;
    _animateCount = 0;
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{ [self setWaitImageToBig:self.imgWait1]; }
                     completion:^(BOOL Finished){ [self animateNext]; }];
}

- (void)animateNext
{
    if (!_animate)
    {
        [self setWaitImagesToSmall];
        return;
    }
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         switch (_animateCount)
                         {
                             case 0:
                                 [self setWaitImageToSmall:self.imgWait1];
                                 [self setWaitImageToBig:self.imgWait2];
                                 break;
                             case 1:
                                 [self setWaitImageToSmall:self.imgWait2];
                                 [self setWaitImageToBig:self.imgWait3];
                                 break;
                             case 3:
                                 [self setWaitImageToSmall:self.imgWait3];
                                 [self setWaitImageToBig:self.imgWait4];
                                 break;
                             case 4:
                                 [self setWaitImageToSmall:self.imgWait4];
                                 [self setWaitImageToBig:self.imgWait5];
                                 break;
                             case 5:
                                 [self setWaitImageToSmall:self.imgWait5];
                                 [self setWaitImageToBig:self.imgWait6];
                                 break;
                             case 6:
                                 [self setWaitImageToSmall:self.imgWait6];
                                 [self setWaitImageToBig:self.imgWait7];
                                 break;
                             case 7:
                                 [self setWaitImageToSmall:self.imgWait7];
                                 [self setWaitImageToBig:self.imgWait8];
                                 break;
                             case 8:
                                 [self setWaitImageToSmall:self.imgWait8];
                                 [self setWaitImageToBig:self.imgWait1];
                                 break;
                             default:
                                 break;
                         }
                         
                         _animateCount++;
                         if (_animateCount > 8)
                             _animateCount = 0;
                     }
                     completion:^(BOOL Finished){ [self animateNext]; }];
}

@end
