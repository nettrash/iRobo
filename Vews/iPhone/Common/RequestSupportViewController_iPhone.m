//
//  RequestSupportViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 01.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "RequestSupportViewController_iPhone.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "AppDelegate.h"
#import "NSNumber+Currency.h"
#import "NSDate+Operation.h"

@interface RequestSupportViewController_iPhone ()

@property (nonatomic, retain) svcHistoryOperation *operation;
@property (nonatomic, retain) IBOutlet UITextView *tvRequest;
@property (nonatomic, retain) IBOutlet UIView *vWait;

@end

@implementation RequestSupportViewController_iPhone

@synthesize delegate = _delegate;
@synthesize operation = _operation;
@synthesize tvRequest = _tvRequest;
@synthesize vWait = _vWait;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.operation = nil;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andHistoryOperation:(svcHistoryOperation *)op
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.operation = op;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vWait.hidden = YES;
    [self initializeInterface];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initializeInterface
{
    if (self.operation != nil)
    {
        NSString *dateStr = [[self.operation.op_RegDate operationDate] lowercaseString];
        NSString *agentStr = [self.operation.currName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([agentStr hasPrefix:@"RUR "])
            agentStr = [agentStr substringFromIndex:4];
        NSString *summaStr = [self.operation.op_Sum numberWithCurrency];
        NSString *stateStr = NSLocalizedString(@"OpInProgress", @"OpInProgress");
        
        if ([self.operation.process isEqualToString:@"Done"])
            stateStr = NSLocalizedString(@"OpDone", @"OpDone");
        if ([self.operation.process isEqualToString:@"Cancel"])
            stateStr = NSLocalizedString(@"OpCancel", @"OpCancel");
        
        NSString *template = [NSString stringWithFormat:NSLocalizedString(@"RequestSupport_Template_ExchangeOperation", @"RequestSupport_Template_ExchangeOperation"), dateStr, agentStr, summaStr, stateStr];
        if (self.operation.check_Id > 0)
            template = [NSString stringWithFormat:NSLocalizedString(@"RequestSupport_Template_ShopOperation", @"RequestSupport_Template_ShopOperation"), dateStr, self.operation.check_MerchantName, summaStr, self.operation.check_MerchantOrder, stateStr];
        if (self.operation.charity_Id > 0)
            template = [NSString stringWithFormat:NSLocalizedString(@"RequestSupport_Template_CharityOperation", @"RequestSupport_Template_CharityOperation"), dateStr, self.operation.charity_Name, summaStr, stateStr];
        self.tvRequest.text = template;
    }
    else
    {
        self.tvRequest.text = @"";
    }
    [self.tvRequest becomeFirstResponder];
}

- (IBAction)btnSend_Click:(id)sender
{
    [self.tvRequest resignFirstResponder];
    self.vWait.hidden = NO;
    NSString *subject = NSLocalizedString(@"RequestSupport_Subject_Standart", @"RequestSupport_Subject_Standart");
    NSString *body = self.tvRequest.text;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app showWait:NSLocalizedString(@"RequestSupport_Wait", @"RequestSupport_Wait")];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    if (self.operation != nil) {
        [svc StoreMessageToSupport:self action:@selector(sendMessageHandler:) UNIQUE:[app.userProfile uid] Subject:subject Body:body OpKey:self.operation.op_Key];
    } else {
        [svc SendMessageToSupport:self action:@selector(sendMessageHandler:) UNIQUE:[app.userProfile uid] Subject:subject Body:body];
    }
}

- (void)sendMessageHandler:(id)response
{
    self.vWait.hidden = YES;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app hideWait];
    
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *resp = (svcWSResponse *)response;
        if (resp.result)
        {
            [self.delegate requestSupportFinished:self];
            return;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"RequestSupport_Title", @"RequestSupport_Title") message:NSLocalizedString(@"RequestSupport_ErrorMessage", @"RequestSupport_ErrorMessage") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
}

- (IBAction)btnCancel_Click:(id)sender
{
    [self.delegate requestSupportFinished:self];
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
