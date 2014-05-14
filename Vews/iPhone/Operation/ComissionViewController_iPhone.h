//
//  ComissionViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 04.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComissionAcceptDelegate.h"

@interface ComissionViewController_iPhone : UIViewController <UIAlertViewDelegate>
{
    NSString *_currency;
    NSDecimalNumber *_summa;
    int _card_Id;
    NSString *_backImageName;
}

@property (nonatomic, retain) id<ComissionAcceptDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currency:(NSString*)curr OutSumma:(NSDecimalNumber *)summ cardId:(int)card_Id;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil currency:(NSString*)curr OutSumma:(NSDecimalNumber *)summ cardId:(int)card_Id andBackground:(NSString *)backImageName;
- (void)addToViewController:(UIViewController *)controller;
- (void)removeFromViewController;

@end
