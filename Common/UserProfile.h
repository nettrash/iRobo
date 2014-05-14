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
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *password;
/*Only iCloud stored*/
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *secondName;
@property (nonatomic, retain) NSString *address;

+ (UserProfile *)load:(NSManagedObjectContext*)objectContext;

- (BOOL)needToRegister;
- (void)saveChanges;
- (BOOL)checkPhone:(NSString *)sPhone;
- (BOOL)setProfilePhone:(NSString *)sPhone;
- (BOOL)checkEMail:(NSString *)sEMail;
- (BOOL)setProfileEMail:(NSString *)sEMail;
- (BOOL)needToApprove;

- (void)registerProfile;
- (void)storeToCloud;
- (void)storeUserDataToCloud;

@end
