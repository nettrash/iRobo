//
//  EditFavoriteViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 04.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditFavoriteDelegate.h"

@interface EditFavoriteViewController_iPhone : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFavorite:(svcFavorite *)fav;

@property (nonatomic, retain) id<EditFavoriteDelegate> delegate;

@end
