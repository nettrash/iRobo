//
//  NumberPadViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 24.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumberPadViewController_iPhone : UIViewController

@property (nonatomic, retain) UITextField *textField;

@property (nonatomic, retain) id target;
@property (nonatomic) SEL action;

@end
