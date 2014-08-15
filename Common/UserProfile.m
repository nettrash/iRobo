//
//  UserProfile.m
//  iRobo
//
//  Created by Ivan Alekseev on 26.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UserProfile.h"
#import "UserProfileEntity.h"
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"

@implementation UserProfile

@synthesize email = _email;
@synthesize phone = _phone;
@synthesize emailApproved = _emailApproved;
@synthesize phoneApproved = _phoneApproved;
@synthesize hasPassword = _hasPassword;
@synthesize uid = _uid;
@synthesize password = _password;
@synthesize lastName = _lastName;
@synthesize firstName = _firstName;
@synthesize secondName = _secondName;
@synthesize address = _address;
@synthesize ofertaAccepted = _ofertaAccepted;
@synthesize isDemoMode = _isDemoMode;

+ (UserProfile *)load:(NSManagedObjectContext*)objectContext
{
    NSError *error;
    NSManagedObjectModel *objectModel = [[objectContext persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *request = [objectModel fetchRequestTemplateForName:@"UserProfile_Select"];
    NSArray *result = [objectContext executeFetchRequest:request error:&error];
    if (result && [result count] > 0)
    {
        UserProfile *profile = [UserProfile alloc];
        profile.isDemoMode = NO;
        UserProfileEntity *entityProfile = (UserProfileEntity *)[result objectAtIndex:0];
        
        if (entityProfile)
        {
            profile.email = [NSString stringWithString:[entityProfile email]];
            profile.phone = [NSString stringWithString:[entityProfile phone]];
            profile.emailApproved = [entityProfile.emailApproved boolValue];
            profile.phoneApproved = [entityProfile.phoneApproved boolValue];
            profile.hasPassword = [entityProfile.hasPassword boolValue];
            profile.password = [NSString stringWithString:[entityProfile password]];
            profile.uid = [NSString stringWithString:[entityProfile uid]];
            [profile loadUserDataFromCloud];
        }
        else
        {
            [profile restoreFromCloud];
            if ([profile uid] && [profile.uid isEqualToString:@""])
                profile.uid = [profile getUUID];
            entityProfile = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfileEntity" inManagedObjectContext:objectContext];
            entityProfile.email = [NSString stringWithString:[profile email]];
            entityProfile.phone = [NSString stringWithString:[profile phone]];
            entityProfile.emailApproved = [NSNumber numberWithBool:NO];
            entityProfile.phoneApproved = [NSNumber numberWithBool:NO];
            entityProfile.hasPassword = [NSNumber numberWithBool:NO];
            entityProfile.password = [NSString stringWithString:[profile password]];
            entityProfile.uid = [NSString stringWithString:[profile uid]];
            [objectContext save:nil];
            [profile loadUserDataFromCloud];
            [profile storeToCloud];
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
        profile.isDemoMode = NO;
        [profile restoreFromCloud];
        if (profile.uid == nil || ![profile uid] || [profile.uid isEqualToString:@""])
            profile.uid = [profile getUUID];
        if (profile.email == nil || ![profile email])
            profile.email = @"";
        if (profile.phone == nil || ![profile phone])
            profile.phone = @"";
        if (profile.password == nil || ![profile password])
            profile.password = @"";
        UserProfileEntity *entityProfile = [NSEntityDescription insertNewObjectForEntityForName:@"UserProfileEntity" inManagedObjectContext:objectContext];
        entityProfile.email = [NSString stringWithString:[profile email]];
        entityProfile.phone = [NSString stringWithString:[profile phone]];
        entityProfile.emailApproved = [NSNumber numberWithBool:NO];
        entityProfile.phoneApproved = [NSNumber numberWithBool:NO];
        entityProfile.hasPassword = [NSNumber numberWithBool:NO];
        entityProfile.password = [NSString stringWithString:[profile password]];
        entityProfile.uid = [NSString stringWithString:[profile uid]];
        [objectContext save:nil];
        [profile loadUserDataFromCloud];
        [profile storeToCloud];
        return profile;
    }
}

+ (UserProfile *)demoProfile
{
    UserProfile *p = [UserProfile alloc];
    p.isDemoMode = YES;
    p.uid = @"6C1D393C-82C5-4873-9354-D50EA7AC5199";
    p.password = @"0000";
    p.hasPassword = YES;
    p.phone = @"+79031234567";
    p.email = @"robot@roboxchange.com";
    p.phoneApproved = YES;
    p.emailApproved = YES;
    p.ofertaAccepted = YES;
    
    return p;
}

- (BOOL)needToRegister
{
    return !self.hasPassword || !self.ofertaAccepted;
}

- (BOOL)needToApprove
{
    return ![self needToRegister] && (!self.emailApproved || !self.phoneApproved);
}

- (void)saveChanges
{
    if (self.isDemoMode) return;
    //Store local
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error = nil;
    NSManagedObjectContext *objectContext = [app managedObjectContext];
    NSManagedObjectModel *objectModel = [[objectContext persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *request = [objectModel fetchRequestTemplateForName:@"UserProfile_Select"];
    NSArray *result = [objectContext executeFetchRequest:request error:&error];
    if (result && [result count] > 0)
    {
        UserProfileEntity *entityProfile = (UserProfileEntity *)[result objectAtIndex:0];
        if (entityProfile)
        {
            entityProfile.email = [NSString stringWithString:[self email]];
            entityProfile.phone = [NSString stringWithString:[self phone]];
            entityProfile.emailApproved = [NSNumber numberWithBool:self.emailApproved];
            entityProfile.phoneApproved = [NSNumber numberWithBool:self.phoneApproved];
            entityProfile.hasPassword = [NSNumber numberWithBool:self.hasPassword];
            entityProfile.password = [NSString stringWithString:[self password]];
            entityProfile.uid = [NSString stringWithString:[self uid]];
            [objectContext save:nil];
        }
    }
}

- (NSString *)getUUID
{
    UIDevice *dev = [UIDevice currentDevice];
    NSString *deviceUuid;
    
    if ([dev respondsToSelector:@selector(identifierForVendor)])
    {
        deviceUuid = [dev.identifierForVendor UUIDString];
    }
    else
    {
        CFStringRef cfUuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
        deviceUuid = [NSString stringWithCString:(char*)cfUuid encoding:NSASCIIStringEncoding];
    }
    return deviceUuid;
}

- (void)storeToCloud
{
    if (self.isDemoMode) return;
    @try {
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self email] forKey:@"email"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self phone] forKey:@"phone"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self password] forKey:@"password"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self uid] forKey:@"uid"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self hasPassword] ? @"YES" : @"NO" forKey:@"has_password"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self phoneApproved] ? @"YES" : @"NO" forKey:@"phone_approved"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self emailApproved] ? @"YES" : @"NO" forKey:@"email_approved"];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void)restoreFromCloud
{
    @try {
        self.email = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"email"];
        self.phone = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"phone"];
        self.password = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"password"];
        self.uid = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"uid"];
        self.hasPassword = [[[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"has_password"] isEqualToString:@"YES"];
        self.phoneApproved = [[[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"phone_approved"] isEqualToString:@"YES"];
        self.emailApproved = [[[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"email_approved"] isEqualToString:@"YES"];
    }
    @catch (NSException *exception) {
        self.hasPassword = NO;
        self.phoneApproved = NO;
        self.emailApproved = NO;
    }
    @finally {
    }
}

- (void)loadUserDataFromCloud
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *v = nil;
    NSString *ln = nil;
    NSString *fn = nil;
    NSString *sn = nil;
    NSString *a = nil;
    v = [app varGet:@"OfertaAccepted"];
    ln = [app varGet:@"LastName"];
    fn = [app varGet:@"FirstName"];
    sn = [app varGet:@"SecondName"];
    a = [app varGet:@"Address"];
    @try {
        if (v == nil) {
            self.ofertaAccepted = [[[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"ofertaAccepted"] isEqualToString:@"YES"];
        }
        else
            self.ofertaAccepted = [v isEqualToString:@"YES"];
    }
    @catch (NSException *exception) {
        self.ofertaAccepted = v ? [v isEqualToString:@"YES"] : NO;
    }
    @finally {
    }
    @try {
        if (ln == nil) {
            self.lastName = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"lastName"];
        }
        else
            self.lastName = ln;
    }
    @catch (NSException *exception) {
        self.lastName = ln ? ln : @"";
    }
    @finally {
    }
    @try {
        if (fn == nil) {
            self.firstName = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"firstName"];
        }
        else
            self.firstName = fn;
    }
    @catch (NSException *exception) {
        self.firstName = fn ? fn : @"";
    }
    @finally {
    }
    @try {
        if (sn == nil) {
            self.secondName = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"secondName"];
        }
        else
            self.secondName = sn;
    }
    @catch (NSException *exception) {
        self.secondName = sn ? sn : @"";
    }
    @finally {
    }
    @try {
        if (a == nil) {
            self.address = [[NSUbiquitousKeyValueStore defaultStore] stringForKey:@"address"];
        }
        else
            self.address = a;
    }
    @catch (NSException *exception) {
        self.address = a ? a : @"";
    }
    @finally {
    }
}

- (void)storeUserDataToCloud
{
    if (self.isDemoMode) return;
    @try {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app varSet:@"OfertaAccepted" value:([self ofertaAccepted] ? @"YES" : @"NO")];
        [app varSet:@"LastName" value:[self lastName]];
        [app varSet:@"FirstName" value:[self firstName]];
        [app varSet:@"SecondName" value:[self secondName]];
        [app varSet:@"Address" value:[self address]];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self ofertaAccepted] ? @"YES" : @"NO" forKey:@"ofertaAccepted"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self lastName] forKey:@"lastName"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self firstName] forKey:@"firstName"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self secondName] forKey:@"secondName"];
        [[NSUbiquitousKeyValueStore defaultStore] setString:[self address] forKey:@"address"];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (BOOL)checkPhone:(NSString *)sPhone
{
    NSString *expression = @"^\\+7[0-9]{10}$";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:sPhone options:0 range:NSMakeRange(0, [sPhone length])];
    
    if (match){
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)setProfilePhone:(NSString *)sPhone
{
    BOOL checkResult = [self checkPhone:sPhone];
    if (checkResult)
    {
        self.phone = sPhone;
    }
    return checkResult;
}

- (BOOL)checkEMail:(NSString *)sEMail
{
    NSString *expression = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:sEMail options:0 range:NSMakeRange(0, [sEMail length])];
    
    if (match){
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)setProfileEMail:(NSString *)sEMail
{
    BOOL checkResult = [self checkEMail:sEMail];
    if (checkResult)
    {
        self.email = sEMail;
    }
    return checkResult;
}

- (void)registerProfile
{
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc SaveSettings:self action:@selector(saveSettingsHandler:) UNIQUE:[self uid] Phone:[self phone] EMail:[self email]];
}

- (void)saveSettingsHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            svcWSMobileBANK *svc = [svcWSMobileBANK service];
            svc.logging = YES;
            [svc SetPassword:self action:@selector(setPasswordHandler:) UNIQUE:[self uid] Password:[self password]];
        }
        else
        {
            [self showSaveError];
        }
        return;
    }
    [self showSaveError];
}

- (void)setPasswordHandler:(id)response
{
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            [self saveChanges];
            [self storeToCloud];
        }
        else
        {
            [self showSaveError];
        }
        return;
    }
    [self showSaveError];
}

- (void)showSaveError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UserProfile_SaveSettings_ErrorTitle", @"UserProfile_SaveSettings_ErrorTitle") message:NSLocalizedString(@"UserProfile_SaveSettings_ErrorMessage", @"UserProfile_SaveSettings_ErrorMessage") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
    [alert show];
}

@end
