//
//  MoneyTransferViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 30.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayViewControllerDelegate.h"
#import "svcCard.h"
#import "CardsViewControllerDelegate.h"
#import "EnterCVCDelegate.h"
#import "OperationStateDelegate.h"
#import "ComissionAcceptDelegate.h"
#import "ComissionViewController_iPhone.h"

@interface MoneyTransferViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CardsViewControllerDelegate, EnterCVCDelegate, OperationStateDelegate, ComissionAcceptDelegate>
{
    BOOL _keyboardIsShowing;
    NSNumber *_keyboardHeight;

    svcCard *_card;
    NSString *_cvc;
    ComissionViewController_iPhone *_comissionViewController;
    NSDecimalNumber *_summa;
}

@property (nonatomic, retain) id<PayViewControllerDelegate> delegate;

@end
