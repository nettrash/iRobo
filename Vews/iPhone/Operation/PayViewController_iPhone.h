//
//  PayViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 07.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayViewControllerDelegate.h"
#import "svcTopCurrency.h"
#import "svcCard.h"
#import "CardsViewControllerDelegate.h"
#import "EnterCVCDelegate.h"
#import "OperationStateDelegate.h"
#import "ComissionAcceptDelegate.h"
#import "ComissionViewController_iPhone.h"

@interface PayViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CardsViewControllerDelegate, EnterCVCDelegate, OperationStateDelegate, ComissionAcceptDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL _isRefreshing;
    BOOL _firstInitialize;
    svcTopCurrency *_topCurrency;
    NSString *_currencyLabel;
    NSArray *_parameters;
    BOOL _keyboardIsShowing;
    NSNumber *_keyboardHeight;
    svcCard *_card;
    NSString *_cvc;
    BOOL _needToShowDoneButton;
    ComissionViewController_iPhone *_comissionViewController;
    NSDecimalNumber *_summa;
}

@property (nonatomic, retain) id<PayViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTopCurrency:(svcTopCurrency *)currency;

@end
