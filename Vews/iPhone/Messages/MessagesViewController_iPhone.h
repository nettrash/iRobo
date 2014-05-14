//
//  MessagesViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSString *_timestamp;
    NSMutableArray *_messages;
    NSIndexPath *_selectedIndexPath;
}

@end
