//
//  PayCheckViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 07.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcCheck.h"
#import "PayViewControllerDelegate.h"
#import "EnterCVCDelegate.h"
#import "svcCard.h"
#import "OperationStateDelegate.h"
#import "CardsViewControllerDelegate.h"

@interface PayCheckViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, EnterCVCDelegate, OperationStateDelegate, CardsViewControllerDelegate>
{
    int _selectedCurrency;
    NSArray *_selectedCurrencyParameters;
    UIPickerView *_pvMethods;
    BOOL _keyboardIsShowing;
    NSNumber *_keyboardHeight;
    svcCard *_card;
    NSString *_cvc;
    BOOL _parameterRefreshing;
    NSMutableDictionary *_parameters;
}

@property (nonatomic, retain) id<PayViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withCheck:(svcCheck *)check;

@end
