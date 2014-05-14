//
//  UIParameterTextField.h
//  iRobo
//
//  Created by Ivan Alekseev on 07.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcParameter.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

@interface UIParameterTextField : UITextField <UIPickerViewDataSource, UIPickerViewDelegate, ABPeoplePickerNavigationControllerDelegate>
{
    UIPickerView *_pvOptions;
}

@property (nonatomic, retain) svcParameter *parameter;

- (id)initWithFrame:(CGRect)frame andParameter:(svcParameter *)prm;

@end
