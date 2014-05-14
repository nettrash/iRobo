//
//  WaitingViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 28.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitingViewController_iPhone : UIViewController
{
    BOOL _animate;
    int _animateCount;
}

- (void)startAnimation:(NSString *)message;
- (void)stopAnimation;

@end
