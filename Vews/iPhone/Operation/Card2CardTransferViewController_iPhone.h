//
//  Card2CardTransferViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 29.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayViewControllerDelegate.h"
#import "EnterCVCDelegate.h"
#import "OperationStateDelegate.h"
#import "AddCardDelegate.h"

@interface Card2CardTransferViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, EnterCVCDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, OperationStateDelegate, AddCardViewControllerDelegate>
{
    NSArray *_cards;
    BOOL _keyboardIsShowing;
    NSNumber *_keyboardHeight;
}

@property (nonatomic, retain) id<PayViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withToCardNumber:(NSString *)toCardNumber;
- (void)initToCardNumber:(NSString *)toCardNumber;

@end
