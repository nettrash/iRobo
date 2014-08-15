//
//  ProfileViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    BOOL _keyboardIsShowing;
    NSNumber *_keyboardHeight;
}

@end
