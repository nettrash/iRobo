//
//  BlankViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 03.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OperationBlankDelegate.h"
#import "svcHistoryOperation.h"

@interface BlankViewController_iPhone : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) id<OperationBlankDelegate> delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withOperation:(svcHistoryOperation *)op;

@end
