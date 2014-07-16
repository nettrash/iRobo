//
//  HistoryFinalizeCellView_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 07.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryFinalizeCellView_iPhone : UITableViewCell

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *aiWait;
@property (nonatomic, retain) IBOutlet UILabel *lblMessage;

@end
