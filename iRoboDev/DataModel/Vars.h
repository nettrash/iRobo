//
//  Vars.h
//  iRobo
//
//  Created by Ivan Alekseev on 05.08.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Vars : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * value;

@end
