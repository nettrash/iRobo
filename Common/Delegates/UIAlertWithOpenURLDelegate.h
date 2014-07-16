//
//  UIAlertWithOpenURLDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 06.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertWithOpenURLDelegate : NSObject <UIAlertViewDelegate>

@property (nonatomic, retain) NSURL *url;

+ (id)initWithText:(NSString *)str;

@end
