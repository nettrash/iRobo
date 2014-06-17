//
//  OperationStateViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 23.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "OperationStateViewController_iPhone.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "NSString+Checkers.h"
#import "AdditionalParametersViewController_iPhone.h"

@interface OperationStateViewController_iPhone ()

@property (nonatomic, retain) IBOutlet UILabel *lblComments;
@property (nonatomic, retain) IBOutlet UIWebView *wvComments;

@end

@implementation OperationStateViewController_iPhone

@synthesize delegate = _delegate;
@synthesize lblComments = _lblComments;
@synthesize wvComments = _wvComments;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil OpKey:(NSString *)OpKey
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _opKey = OpKey;
        _3DShowed = NO;
        self.navigationItem.title = NSLocalizedString(@"PaymentState_Title", @"PaymentState_Title");
        [self.navigationItem setHidesBackButton:YES animated:YES];
        UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        ai.hidesWhenStopped = YES;
        [ai startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:ai];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wvComments.hidden = YES;
    [self performSelector:@selector(checkOperation:) withObject:nil afterDelay:5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showAdditionalParameters:(NSArray *)parameters
{
    AdditionalParametersViewController_iPhone *pp = [[AdditionalParametersViewController_iPhone alloc] initWithNibName:@"AdditionalParametersViewController_iPhone" bundle:nil withParameters:parameters];
    pp.delegate = self;
    [self.navigationController pushViewController:pp animated:YES];
}

- (void)applyParameters:(NSArray *)parameters
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    for (svcParameter *p in parameters)
    {
        [a addObject:[NSString stringWithFormat:@"%@:%@", p.Name, p.DefaultValue]];
    }
    NSString *prms = [a componentsJoinedByString:@";"];
    
    [svc ApproveParameters:self action:@selector(checkOperationHandle:) UNIQUE:[app.userProfile uid] OpKey:_opKey parameters:prms];
}

- (void)checkOperation:(id)sender
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc GetOperationState:self action:@selector(checkOperationHandle:) UNIQUE:[app.userProfile uid] OpKey:_opKey];
}

- (void)checkOperationHandle:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            if (resp.operationState.inputDone)
            {
                [self.delegate operationIsComplete:self success:YES];
                return;
            }
            if ([resp.operationState.Process isEqualToString:@"Cancel"])
            {
                [self.delegate operationIsComplete:self success:NO];
                return;
            }
            if ([resp.operationState.Process isEqualToString:@"Input"] && resp.operationState.Redirect && !_3DShowed)
            {
                //Показываем WebView
                _3DShowed = YES;
                UIWebView *wv3D = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20)];
                wv3D.scalesPageToFit = YES;
                NSURL *URL = [NSURL URLWithString:resp.operationState.Redirect.Url];
                NSURLRequest *rq = [NSURLRequest requestWithURL:URL];
                wv3D.delegate = self;
                [wv3D loadRequest:rq];
                [self.view addSubview:wv3D];
                [self.view bringSubviewToFront:wv3D];
            }
            if (resp.parameters && resp.parameters != nil && [resp.parameters count] > 0)
            {
                [self showAdditionalParameters:resp.parameters];
                return;
            }
            NSString *pc = self.lblComments.text;
            self.lblComments.text = [resp.operationState.Comments componentsJoinedByString:@"\n"];
            if (![pc isEqualToString:self.lblComments.text]) {
                [self.wvComments loadHTMLString:[[resp.operationState.Comments componentsJoinedByString:@"\n"] HTMLWithSystemFont] baseURL:nil];
                self.wvComments.hidden = ![self.lblComments.text isHTML];
            }
        }
    }
    [self performSelector:@selector(checkOperation:) withObject:nil afterDelay:5];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *slURL = webView.request.URL.absoluteString;
    if ([slURL hasPrefix:@"https://misc.roboxchange.com/External/iPhone/redirectToShop.aspx"]) {
        webView.hidden = YES;
        [webView loadHTMLString:@"" baseURL:nil];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *slURL = webView.request.URL.absoluteString;
    if ([slURL hasPrefix:@"https://misc.roboxchange.com/External/iPhone/redirectToShop.aspx"]) {
        webView.hidden = YES;
        [webView loadHTMLString:@"" baseURL:nil];
    }
}

#pragma mark AdditionalParametersDelegate

- (void)parametersEntered:(UIViewController *)controller parameters:(NSArray *)parameters
{
    [self.navigationController popViewControllerAnimated:YES];
    [self applyParameters:parameters];
}

- (void)userCancelAction:(UIViewController *)controller
{
    [self.delegate operationIsComplete:self success:NO];
}

@end
