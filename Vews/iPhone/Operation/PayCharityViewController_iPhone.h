//
//  PayCharityViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 15.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcCharity.h"
#import "PayViewControllerDelegate.h"
#import "ComissionViewController_iPhone.h"
#import "svcCard.h"
#import "CardsViewControllerDelegate.h"
#import "EnterCVCDelegate.h"
#import "OperationStateDelegate.h"
#import "ComissionAcceptDelegate.h"

@interface PayCharityViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CardsViewControllerDelegate, EnterCVCDelegate, OperationStateDelegate, ComissionAcceptDelegate>
{
    svcCharity *_charity;

    BOOL _keyboardIsShowing;
    NSNumber *_keyboardHeight;
    
    svcCard *_card;
    NSString *_cvc;
    ComissionViewController_iPhone *_comissionViewController;
    NSDecimalNumber *_summa;
}

@property (nonatomic, retain) id<PayViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withCharity:(svcCharity *)charity;

@end
