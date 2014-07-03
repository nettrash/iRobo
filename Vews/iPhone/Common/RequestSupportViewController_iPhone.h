//
//  RequestSupportViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 01.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcHistoryOperation.h"
#import "RequestSupportDelegate.h"

@interface RequestSupportViewController_iPhone : UIViewController

@property (nonatomic, retain) id<RequestSupportDelegate> delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andHistoryOperation:(svcHistoryOperation *)op;

@end
