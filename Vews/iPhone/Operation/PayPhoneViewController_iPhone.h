//
//  PayPhoneViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 28.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayViewControllerDelegate.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "svcCurrency.h"
#import "CardsViewController_iPhone.h"
#import "CardsViewControllerDelegate.h"
#import "svcCard.h"
#import "EnterCVCDelegate.h"
#import "svcParameter.h"
#import "OperationStateDelegate.h"
#import "ComissionAcceptDelegate.h"
#import "ComissionViewController_iPhone.h"

@interface PayPhoneViewController_iPhone : UIViewController <UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, CardsViewControllerDelegate, EnterCVCDelegate, OperationStateDelegate, ComissionAcceptDelegate>
{
    svcCurrency *_currency;
    svcParameter *_parameter;
    svcCard *_card;
    NSDecimalNumber *_summa;
    NSArray *_availibleSumms;
    BOOL _keyboardIsShowing;
    NSString *_opKey;
    NSString *_cvc;
    ComissionViewController_iPhone *_comissionViewController;
}

@property (nonatomic, retain) id<PayViewControllerDelegate> delegate;

- (void)keyboardWillShow:(NSNotification *)note;
- (void)keyboardDidShow:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)note;

@end
