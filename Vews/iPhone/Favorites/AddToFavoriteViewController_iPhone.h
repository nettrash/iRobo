//
//  AddToFavoriteViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 04.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddToFavoriteDelegate.h"
#import "svcHistoryOperation.h"

@interface AddToFavoriteViewController_iPhone : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withOperation:(svcHistoryOperation *)op;

@property (nonatomic, retain) id<AddToFavoriteDelegate> delegate;

@end
