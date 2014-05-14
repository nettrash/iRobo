//
//  UserProfileEntity.h
//  iRobo
//
//  Created by Ivan Alekseev on 30.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserProfileEntity : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * emailApproved;
@property (nonatomic, retain) NSNumber * phoneApproved;
@property (nonatomic, retain) NSNumber * hasPassword;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * uid;

@end
