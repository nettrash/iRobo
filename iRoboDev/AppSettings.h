//
//  AppSettings.h
//  iRobo
//
//  Created by Ivan Alekseev on 24.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject

@property (nonatomic) BOOL blurWhenBackground;
@property (nonatomic) NSInteger passwordTimeout;
@property (nonatomic) BOOL useSound;

- (void)loadSettings;

@end
