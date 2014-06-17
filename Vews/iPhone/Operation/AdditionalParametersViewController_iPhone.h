//
//  AdditionalParametersViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 20.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdditionalParametersDelegate.h"

@interface AdditionalParametersViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSArray *_parameters;
    BOOL _keyboardIsShowing;
    NSNumber *_keyboardHeight;
    BOOL _needToShowDoneButton;
}

@property (nonatomic, retain) id<AdditionalParametersDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withParameters:(NSArray *)parameters;

@end
