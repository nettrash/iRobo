//
//  HistoryViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayViewControllerDelegate.h"
#import "ActivityProtocols.h"
#import "BlankViewControllerDelegate.h"

@interface HistoryViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, PayViewControllerDelegate, ActivityResultDelegate, BlankViewControllerDelegate>
{
    int _Id;
    int _Count;
    NSMutableArray *_history;
    NSMutableArray *_historyCache;
    BOOL _isLoadingCache;
    NSIndexPath *_selectedIndexPath;
    NSArray *_activities;
}

@end
