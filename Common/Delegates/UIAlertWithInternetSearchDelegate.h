//
//  UIAlertWithInternetSearchDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 06.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertWithInternetSearchDelegate : NSObject <UIAlertViewDelegate>

@property (nonatomic, retain) NSString *Q;
@property (nonatomic, retain) NSString *preparedQ;

+ (id)initWithQ:(NSString *)Q;

@end