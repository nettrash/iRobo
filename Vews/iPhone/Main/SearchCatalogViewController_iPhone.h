//
//  SearchCatalogViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 08.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCatalogDelegate.h"

@interface SearchCatalogViewController_iPhone : UIViewController <UISearchBarDelegate>
{
    BOOL _firstSearch;
    NSArray *_catalog;
    BOOL _isRefreshing;
}

@property (nonatomic, retain) id<SearchCatalogDelegate> delegate;

@end
