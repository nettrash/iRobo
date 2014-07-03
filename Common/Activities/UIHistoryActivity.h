//
//  UIHistoryActivity.h
//  iRobo
//
//  Created by Ivan Alekseev on 01.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityProtocols.h"

@interface UIHistoryActivity : UIActivity

@property (nonatomic) BOOL performByButton;
@property (nonatomic, retain) id<ActivityResultDelegate> resultDelegate;

- (UIHistoryActivity *)initWithResultDelegate:(id<ActivityResultDelegate>)delegate;
- (UIImage *)activityMiniImage;
- (UIButton *)activityButtonWithIndex:(int)buttonIndex;
- (IBAction)activityButtonClick:(id)sender;
- (void)activityDidFinishByButton;

@end
