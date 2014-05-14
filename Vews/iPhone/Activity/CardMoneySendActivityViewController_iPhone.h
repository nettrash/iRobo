//
//  CardSendMoneyActivityViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 17.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcCard.h"
#import "ActivityProtocols.h"
#import "Enums.h"
#import "EnterCVCDelegate.h"

@interface CardMoneySendActivityViewController_iPhone : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, EnterCVCDelegate, UIWebViewDelegate>
{
    MoneySendFormType _formType;
    BOOL _keyboardIsShowing;
    BOOL _needToShowDoneButton;
    NSString *_opKey;
}

@property (nonatomic) id<CardMoneySendActivityViewControllerDelegate> delegate;
@property (nonatomic, retain) svcCard *card;
@property (nonatomic, retain) NSMutableArray *cards;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil formType:(MoneySendFormType)formType;

- (void)keyboardWillShow:(NSNotification *)note;
- (void)keyboardDidShow:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)note;

- (void)addDoneButtonToNumberPadKeyboard;
- (void)removeDoneButtonFromNumberPadKeyboard;

@end
