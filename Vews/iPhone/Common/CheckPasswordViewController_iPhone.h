//
//  CheckPasswordViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 08.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckPasswordDelegate.h"

@interface CheckPasswordViewController_iPhone : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) id<CheckPasswordDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDelegate:(id<CheckPasswordDelegate>)delegate;
- (void)prepareView;

@end
