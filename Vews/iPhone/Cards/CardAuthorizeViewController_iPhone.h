//
//  CardAuthorizeViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 18.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardAuthorizeViewControllerDelegate.h"
#import "EnterCVCDelegate.h"

@interface CardAuthorizeViewController_iPhone : UIViewController <EnterCVCDelegate, UIWebViewDelegate>
{
    BOOL _keyboardIsShowing;
    BOOL _3DShowed;
    BOOL _Stoped;
    int _failtocheckcount;
}

@property (nonatomic, retain) id<CardAuthorizeViewControllerDelegate> delegate;
@property (nonatomic) int card_Id;
@property (nonatomic) BOOL card_InAuthorize;
@property (nonatomic, retain) UIWebView *wv3D;

@end
