//
//  ActivityAction.h
//  iRobo
//
//  Created by Ivan Alekseev on 22.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityAction : NSObject

@property (nonatomic, retain) NSObject *target;
@property (nonatomic) SEL selector;

@end
