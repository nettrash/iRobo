//
//  OperationStateViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 23.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OperationStateDelegate.h"

@interface OperationStateViewController_iPhone : UIViewController <UIWebViewDelegate>
{
    NSString *_opKey;
    BOOL _3DShowed;
}

@property (nonatomic, retain) id<OperationStateDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil OpKey:(NSString *)OpKey;

@end
