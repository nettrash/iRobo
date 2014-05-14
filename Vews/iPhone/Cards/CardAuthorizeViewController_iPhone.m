//
//  CardAuthorizeViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 18.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "CardAuthorizeViewController_iPhone.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "EnterCVCViewController_iPhone.h"

@interface CardAuthorizeViewController_iPhone ()

@property (nonatomic, retain) EnterCVCViewController_iPhone *cvcView;

@end

@implementation CardAuthorizeViewController_iPhone

@synthesize delegate = _delegate;
@synthesize card_Id = _card_Id;
@synthesize card_InAuthorize = _card_InAuthorize;
@synthesize doneButton = _doneButton;
@synthesize cvcView = _cvcView;
@synthesize wv3D = _wv3D;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"AuthorizeCard_Title", @"AuthorizeCard_Title");
        [self.navigationItem setHidesBackButton:YES animated:YES];

        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.doneButton.frame = CGRectMake(0, 163, 106, 53);
        self.doneButton.adjustsImageWhenHighlighted = NO;
        
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateApplication];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateDisabled];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateHighlighted];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateReserved];
        [self.doneButton setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateSelected];
        _3DShowed = NO;
        _Stoped = NO;
        _failtocheckcount = 0;
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
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardDidShow:)
     name:UIKeyboardDidShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
    
    _keyboardIsShowing = NO;

    if (self.card_InAuthorize)
    {
        [self performSelector:@selector(checkAuthorize) withObject:nil afterDelay:5];
    }
    else
    {
        [self performSelector:@selector(enterCVC) withObject:nil afterDelay:1];
    }
}

- (void)keyboardWillShow : (NSNotification *) note
{
	if (_keyboardIsShowing) return;
    if (_3DShowed)
        [self removeDoneButtonFromNumberPadKeyboard];
    else
        [self addDoneButtonToNumberPadKeyboard];
    
	_keyboardIsShowing = YES;
}

- (void)keyboardDidShow : (NSNotification *) note
{
    if (_3DShowed)
        [self removeDoneButtonFromNumberPadKeyboard];
    else
        [self addDoneButtonToNumberPadKeyboard];
}

- (void)keyboardWillHide : (NSNotification *) note
{
    if (_keyboardIsShowing == YES) {
        _keyboardIsShowing = NO;
	}
}

- (void)addDoneButtonToNumberPadKeyboard
{
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for (int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                [keyboard addSubview:self.doneButton];
        } else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                [keyboard addSubview:self.doneButton];
        }
    }
}

- (void)removeDoneButtonFromNumberPadKeyboard
{
	if (!_keyboardIsShowing) return;
	
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for (int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                break;
        } else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                break;
        }
    }
	for ( int i = 0; i < [keyboard.subviews count]; i++) {
		if ([[keyboard.subviews objectAtIndex:i] isKindOfClass:[UIButton class]]) {
			UIButton *btnDone = (UIButton *)[keyboard.subviews objectAtIndex:i];
			if (btnDone == self.doneButton) {
				[self.doneButton removeFromSuperview];
				return;
			}
		}
	}
}

- (void)enterCVC
{
    self.cvcView = [[EnterCVCViewController_iPhone alloc] initWithNibName:@"EnterCVCViewController_iPhone" bundle:nil];
    self.cvcView.delegate = self;
    [self.doneButton addTarget:self.cvcView action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.cvcView performSelector:@selector(addToViewController:) withObject:self afterDelay:.1];
}

- (void)beginAuthorize:(NSString *)cvc
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc BeginAuthorizeCard:self action:@selector(beginAuthorizeHandler:) UNIQUE:[app.userProfile uid] cardId:self.card_Id cvc:cvc];
}

- (void)beginAuthorizeHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            [self performSelectorOnMainThread:@selector(checkAuthorize) withObject:nil waitUntilDone:5];
        }
    }
}

- (void)checkAuthorize
{
    if (_Stoped) return;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc CheckAuthorizeCardWith3D:self action:@selector(checkAuthorizeCardHandler:) UNIQUE:[app.userProfile uid] cardId:self.card_Id];
}

- (void)checkAuthorizeCardHandler:(id)response
{
    if (_Stoped) return;
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.authComplete)
            {
                _Stoped = YES;
                [self performSelector:@selector(authComplete) withObject:nil afterDelay:.1];
            }
            else
            {
                if (resp.authNeed3D)
                {
                    [self performSelector:@selector(authShow3D:) withObject:[NSNumber numberWithInt:resp.authCdId] afterDelay:.1];
                    _Stoped = YES;
                }
                else
                {
                    if (resp.authRequestSum)
                    {
                        _Stoped = YES;
                        [self performSelector:@selector(authRequestSum) withObject:nil afterDelay:.1];
                    }
                    else
                    {
                        if ([resp.authMode isEqualToString:@"BLOCK"] && [resp.authState isEqualToString:@"REJECTED"])
                        {
                            _Stoped = YES;
                            [self performSelector:@selector(authRejected) withObject:nil afterDelay:.1];
                        }
                        else
                        {
                            if (([resp.authMode isEqualToString:@"BLOCK"] || [resp.authMode isEqualToString:@"REJECT"]) && [resp.authState isEqualToString:@"ACCEPTED"])
                            {
                                _Stoped = YES;
                                [self performSelector:@selector(authComplete) withObject:nil afterDelay:.1];
                            }
                            else
                            {
                                [self performSelector:@selector(checkAuthorize) withObject:nil afterDelay:5];
                            }
                        }
                    }
                }
            }
        }
        else
        {
            if ([resp.errorcode isEqualToString:@"failtocheckauthorizecard"])
            {
                if (_failtocheckcount++ > 5)
                {
                    _Stoped = YES;
                    [self performSelector:@selector(authRejected) withObject:nil afterDelay:.1];
                }
                else
                {
                    _Stoped = NO;
                    [self performSelector:@selector(checkAuthorize) withObject:nil afterDelay:10];
                }
            }
            else
            {
                _Stoped = NO;
                [self performSelector:@selector(checkAuthorize) withObject:nil afterDelay:10];
            }
        }
    }
    else
    {
        _Stoped = NO;
        [self performSelector:@selector(checkAuthorize) withObject:nil afterDelay:15];
    }
}

- (void)authComplete
{
    [self.delegate finishAuthorizeAction:self];
}

- (void)authRejected
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AuthCard_Rejected_Title", @"AuthCard_Rejected_Title") message:NSLocalizedString(@"AuthCard_Rejected_Message", @"AuthCard_Rejected_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
    [self.delegate finishAuthorizeAction:self];
}

- (void)authShow3D:(NSNumber *)cdId
{
    _3DShowed = YES;
    self.wv3D = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://auth.robokassa.ru/Payment/Verify.aspx?Id=%i", [cdId intValue]]];
    NSURLRequest *rq = [NSURLRequest requestWithURL:URL];
    self.wv3D.delegate = self;
    [self.wv3D loadRequest:rq];
    [self.view addSubview:self.wv3D];
    [self.view bringSubviewToFront:self.wv3D];
}

- (void)authRequestSum
{
    NSLog(@"authRequestSum");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark EnterCVCDelegate

-(void)finishEnterCVC:(UIViewController *)controller cvcEntered:(BOOL)cvcEntered cvcValue:(NSString*)cvcValue
{
    if (cvcEntered)
    {
        [(EnterCVCViewController_iPhone *)controller removeFromViewController];
        [self performSelector:@selector(beginAuthorize:) withObject:cvcValue afterDelay:.1];
    }
    else
    {
        [self.delegate finishAuthorizeAction:self];
    }
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    NSString *slURL = webView.request.URL.absoluteString;
    if ([slURL isEqualToString:@""]) return;
    if (([slURL rangeOfString:@"auth.robokassa.ru"].location != NSNotFound &&
         [slURL rangeOfString:@"Verify.aspx"].location == NSNotFound) ||
        ([slURL rangeOfString:@"misc.roboxchange.com"].location != NSNotFound &&
         [slURL rangeOfString:@"secureDone.aspx"].location != NSNotFound))
    {
        [webView removeFromSuperview];
        [webView loadHTMLString:@"" baseURL:nil];
        _3DShowed = NO;
        _Stoped = NO;
        _failtocheckcount = 0;
        [self performSelector:@selector(checkAuthorize) withObject:nil afterDelay:5];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *slURL = webView.request.URL.absoluteString;
    if ([slURL isEqualToString:@""]) return;
    if (([slURL rangeOfString:@"auth.robokassa.ru"].location != NSNotFound &&
         [slURL rangeOfString:@"Verify.aspx"].location == NSNotFound) ||
        ([slURL rangeOfString:@"misc.roboxchange.com"].location != NSNotFound &&
         [slURL rangeOfString:@"secureDone.aspx"].location != NSNotFound))
    {
        [webView removeFromSuperview];
        [webView loadHTMLString:@"" baseURL:nil];
        _3DShowed = NO;
        _Stoped = NO;
        _failtocheckcount = 0;
        [self performSelector:@selector(checkAuthorize) withObject:nil afterDelay:5];
    }
}

@end
