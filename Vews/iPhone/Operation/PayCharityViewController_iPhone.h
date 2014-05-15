//
//  PayCharityViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 15.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "svcCharity.h"
#import "PayViewControllerDelegate.h"

@interface PayCharityViewController_iPhone : UIViewController
{
    svcCharity *_charity;
}

@property (nonatomic, retain) id<PayViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withCharity:(svcCharity *)charity;

@end
