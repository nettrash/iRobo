//
//  FavoritesViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayViewControllerDelegate.h"
#import "EditFavoriteDelegate.h"

@interface FavoritesViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, PayViewControllerDelegate, EditFavoriteDelegate>
{
    NSMutableArray *_favorites;
}

@end
