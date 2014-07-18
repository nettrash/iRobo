//
//  EnterCVCViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 18.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnterCVCDelegate.h"

@interface EnterCVCViewController_iPhone : UIViewController <UIAlertViewDelegate>

@property (nonatomic, retain) id<EnterCVCDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withCard:(int)card_Id;
- (void)addToViewController:(UIViewController *)controller;
- (void)removeFromViewController;
- (IBAction)doneButton:(id)sender;
- (void)applyCard:(int)card_Id;

@end
