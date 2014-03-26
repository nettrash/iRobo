//
//  UserProfile.h
//  iRobo
//
//  Created by Ivan Alekseev on 26.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic) BOOL emailApproved;
@property (nonatomic) BOOL phoneApproved;
@property (nonatomic) BOOL hasPassword;

+ (UserProfile *)load;

@end
