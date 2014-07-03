//
//  BlankViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 03.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlankViewControllerDelegate.h"
#import "svcHistoryOperation.h"

@interface BlankViewController_iPhone : UIViewController

@property (nonatomic, retain) id<BlankViewControllerDelegate> delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withOperation:(svcHistoryOperation *)op;

@end
