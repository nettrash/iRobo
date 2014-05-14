//
//  SavedParametersEntity.h
//  iRobo
//
//  Created by Ivan Alekseev on 11.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SavedParametersEntity : NSManagedObject

@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSString * parameter;
@property (nonatomic, retain) NSString * value;

@end
