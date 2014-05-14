//
//  AddCardViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 16.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CardIO.h>
#import "CardAuthorizeViewController_iPhone.h"
#import "CardAuthorizeViewControllerDelegate.h"
#import "AddCardDelegate.h"

@interface AddCardViewController_iPhone : UIViewController <CardIOPaymentViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, CardAuthorizeViewControllerDelegate>
{
    BOOL _keyboardIsShowing;
    NSNumber *_keyboardHeight;
}

@property (nonatomic, retain) id<AddCardViewControllerDelegate> delegate;

@end
