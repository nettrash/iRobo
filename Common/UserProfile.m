//
//  UserProfile.m
//  iRobo
//
//  Created by Ivan Alekseev on 26.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UserProfile.h"
#import "UserProfileEntity.h"

@implementation UserProfile

+ (UserProfile *)load : (AppDelegate *) app
{
    NSError *error;
    NSManagedObjectContext *objectContext = [app managedObjectContext];
    NSManagedObjectModel *objectModel = [[objectContext persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *request = [objectModel fetchRequestTemplateForName:@"UserProfile_Select"];
    NSArray *result = [objectContext executeFetchRequest:request error:&error];
    if (result && [result count] > 0)
    {
        UserProfile *profile = [UserProfile alloc];
        UserProfileEntity *entityProfile = (UserProfileEntity *)[result objectAtIndex:0];
        if (entityProfile)
        {
            profile.email = [NSString stringWithString:[entityProfile email]];
            profile.phone = [NSString stringWithString:[entityProfile phone]];
            profile.emailApproved = entityProfile.emailApproved;
            profile.phoneApproved = entityProfile.phoneApproved;
            profile.hasPassword = entityProfile.hasPassword;
        }
        else
        {
            profile.email = @"";
            profile.phone = @"";
            profile.emailApproved = NO;
            profile.phoneApproved = NO;
            profile.hasPassword = NO;
            entityProfile = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfileEntity" inManagedObjectContext:objectContext];
            entityProfile.email = @"";
            entityProfile.phone = @"";
            entityProfile.emailApproved = NO;
            entityProfile.phoneApproved = NO;
            entityProfile.hasPassword = NO;
            [app saveContext];
        }
        return profile;
    }
    else
    {
        if (error)
        {
            NSLog(@"UserProfile load error. Code %ld. Description %@. Debug description %@.", (long)error.code, error.description, error.debugDescription);
        }
        UserProfile *profile = [UserProfile alloc];
        profile.email = @"";
        profile.phone = @"";
        profile.emailApproved = NO;
        profile.phoneApproved = NO;
        profile.hasPassword = NO;
        UserProfileEntity *entityProfile = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfileEntity" inManagedObjectContext:objectContext];
        entityProfile.email = @"";
        entityProfile.phone = @"";
        entityProfile.emailApproved = NO;
        entityProfile.phoneApproved = NO;
        entityProfile.hasPassword = NO;
        [app saveContext];
        return profile;
    }
}

@end
