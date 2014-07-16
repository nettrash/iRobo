//
//  AppDelegate.m
//  iRoboDev
//
//  Created by Ivan Alekseev on 30.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "AppDelegate.h"
#import "RegisterViewController_iPhone.h"
#import "ApprovePhoneViewController_iPhone.h"
#import "ApproveEMailViewController_iPhone.h"
#import "MainViewController_iPhone.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuViewController_iPhone.h"
#import "MessagesViewController_iPhone.h"
#import "svcWSMobileBANK.h"
#import "Reachability.h"
#import "UIViewController+KeyboardExtensions.h"
#import "CardsViewController_iPhone.h"
#import "NSURL+Parameters.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize userProfile = _userProfile;
@synthesize audioPlayer = _audioPlayer;
@synthesize registerAlertDelegate = _registerAlertDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.registerAlertDelegate = [[UIAlertViewRegisterDelegate alloc] init];
    _firstInitialization = YES;
    _fromBackground = NO;
    _needToProcessLaunchURL = NO;
    _launchURL = nil;
    _waitingView_iPhone = [[WaitingViewController_iPhone alloc] initWithNibName:@"WaitingViewController_iPhone" bundle:nil];
    _checkPasswordView_iPhone = [[CheckPasswordViewController_iPhone alloc] initWithNibName:@"CheckPasswordViewController_iPhone" bundle:nil andDelegate:self];
    _noInternetConnectionView_iPhone = [[NoInternetConnectionViewController_iPhone alloc] initWithNibName:@"NoInternetConnectionViewController_iPhone" bundle:nil];
    _nowWaiting = NO;
    _nowCheckingPassword = NO;
    _netIsWiFi = NO;
    _noInternet = NO;
    _settings = [AppSettings alloc];
    [_settings loadSettings];
    
    NSDictionary *audioProfiles = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"AudioProfiles" withExtension:@"plist"]];
    NSArray *persons = (NSArray *)[audioProfiles objectForKey:@"Persons"];
    _audioProfile = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:(NSString *)[persons objectAtIndex:arc4random() % [persons count]] withExtension:@"plist"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _internetReach = [Reachability reachabilityForInternetConnection];
    [_internetReach startNotifier];
    [self parseCurrentReachability:_internetReach];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.userProfile = [UserProfile load:self.managedObjectContext];
    self.window.backgroundColor = [UIColor whiteColor];

    [self getScenario];
    [self.window makeKeyAndVisible];
    
    if (_firstInitialization)
        [self showWait:NSLocalizedString(@"InitializeApp", @"InitializeApp")];
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationType)(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL b = [self applyLaunchURL:url];
    if (_fromBackground && b)
        [self performSelector:@selector(processLaunchURL) withObject:nil afterDelay:.5];
    return b;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL b = [self applyLaunchURL:url];
    if (_fromBackground && b)
        [self performSelector:@selector(processLaunchURL) withObject:nil afterDelay:.5];
    return b;
}

- (BOOL)applyLaunchURL:(NSURL *)url
{
    if (!url)
        return NO;
    //Готовим линк по ссылке из веба если она присутсвует
    NSString *urlString = [url absoluteString];
    if ([urlString hasPrefix:@"https://misc.roboxchange.com/External/iPhone/linktorobokassa.ashx"]) {
        if ([[url.query uppercaseString] hasPrefix:@"DATA="]) {
            urlString = [url.query substringFromIndex:5];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            urlString = [NSString stringWithFormat:@"robokassa://%@", urlString];
        }
    }
    
    //Если строка наша, то да, иначе нет
    if ([urlString hasPrefix:@"robokassa://"] || [urlString hasPrefix:@"card2card://"]) {
        //Сохраняем команду для обработки
        _launchURL = [NSURL URLWithString:urlString];
        _needToProcessLaunchURL = YES;
        return YES;
    } else {
        _needToProcessLaunchURL = NO;
        return NO;
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *tokenAsString = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    [svc SaveDeviceToken:self action:@selector(saveDeviceTokenHandler:) UNIQUE:[self.userProfile uid] Token:tokenAsString];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Register for remote notification error %@", error);
}

- (void)saveDeviceTokenHandler:(id)response
{
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.window.rootViewController hideKeyboard];
    [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    if (_settings.blurWhenBackground)
        [self addBlur];
    _backgroundDate = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _needToProcessLaunchURL = NO;
    _launchURL = nil;
    _fromBackground = YES;
    if (_settings.blurWhenBackground)
        [self removeBlur];
    [_settings loadSettings];
    [self showCheckPasswordView];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self parseCurrentReachability: curReach];
}

- (void)parseCurrentReachability:(Reachability *)reach
{
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    BOOL connectionRequired = [reach connectionRequired];
    _netIsWiFi = NO;
    switch (netStatus) {
        case NotReachable: {
            connectionRequired = YES;
            break;
        }
        case ReachableViaWWAN:
            break;
        case ReachableViaWiFi:
            _netIsWiFi = YES;
        default:
            break;
    }
    if (connectionRequired)
    {
        [self showNoInternet];
    }
    else
    {
        [self hideNoInternet];
    }
}

- (void)showNoInternet
{
    if (!_noInternet)
    {
        [self.window.rootViewController hideKeyboard];
        [self.window.rootViewController.view addSubview:_noInternetConnectionView_iPhone.view];
        [self.window.rootViewController.view bringSubviewToFront:_noInternetConnectionView_iPhone.view];
        _noInternet = YES;
    }
}

- (void)hideNoInternet
{
    [_noInternetConnectionView_iPhone.view removeFromSuperview];
    _noInternet = NO;
}

#pragma mark - Service methods

- (void)showWait:(NSString *)message
{
    if (!_nowWaiting)
    {
        _nowWaiting = YES;
        [self.window.rootViewController.view addSubview:_waitingView_iPhone.view];
        [self.window.rootViewController.view bringSubviewToFront:_waitingView_iPhone.view];
        [_waitingView_iPhone performSelector:@selector(startAnimation:) withObject:message afterDelay:.1];
    }
}

- (void)hideWait
{
    _nowWaiting = NO;
    [_waitingView_iPhone stopAnimation];
    [_waitingView_iPhone.view removeFromSuperview];
}

- (NSString *)PlatformName
{
    return @"iOS";
}

- (NSString *)DeviceName
{
    return [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
}

- (void)firstTimeInitializationComplete
{
    if (_firstInitialization) {
        _firstInitialization = NO;
        [self hideWait];
        [self showCheckPasswordView];
    }
}

- (void)demoModeAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DEMO MODE" message:NSLocalizedString(@"DEMO_MODE_MESSAGE", @"DEMO_MODE_MESSAGE") delegate:self.registerAlertDelegate cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:NSLocalizedString(@"Button_Register", @"Button_Register"), nil];
    [alert show];
}

#pragma mark - Audio

- (void)playSound:(NSURL *)audioURL
{
    if (!_settings.useSound) return;
    if (self.audioPlayer && self.audioPlayer.isPlaying)
    {
        [self.audioPlayer stop];
    }
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer play];
}

- (void)resumeSound
{
    if (!_settings.useSound) return;
    if (self.audioPlayer && !self.audioPlayer.isPlaying)
    {
        [self.audioPlayer play];
    }
}

- (void)stopSound
{
    if (!_settings.useSound) return;
    if (self.audioPlayer && self.audioPlayer.isPlaying)
    {
        [self.audioPlayer stop];
    }
}

- (void)personVoiceForGroup:(NSString *)group andAction:(NSString *)action
{
    if (!_settings.useSound) return;
    @try {
        NSDictionary *dGroup = (NSDictionary *)[_audioProfile objectForKey:group];
        if (dGroup && dGroup != nil)
        {
            NSArray *aActions = (NSArray *)[dGroup objectForKey:action];
            NSArray *anyActions = (NSArray *)[dGroup objectForKey:@"Any"];
            NSArray *a = [NSArray arrayWithArray:aActions];
            a = [a arrayByAddingObjectsFromArray:anyActions];
            if (a && a != nil && [a count] > 0)
            {
                NSString *file = [a objectAtIndex:arc4random() % [a count]];
                [self playSound:[[NSBundle mainBundle] URLForResource:file withExtension:@"m4a"]];
            }
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void)playProfileSound
{
    if (!_settings.useSound) return;
    NSString *phoneKey = self.userProfile.phone;
    if ([phoneKey hasPrefix:@"+"])
    {
        phoneKey = [phoneKey substringFromIndex:1];
    }
    [self personVoiceForGroup:@"Welcome" andAction:phoneKey];
}

#pragma mark - Bluring

- (UIImage*)blur:(UIImage*)theImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [self scaleIfNeeded:cgImage];
}

- (UIImage*)blurryGPUImage:(UIImage *)image withBlurLevel:(NSInteger)blur andPhases:(NSInteger)phases
{
    GPUImageFastBlurFilter *blurFilter =
    [[GPUImageFastBlurFilter alloc] init];
    blurFilter.blurSize = blur;
    blurFilter.blurPasses = phases;
    return [blurFilter imageByFilteringImage:image];
}

- (UIImage*)scaleIfNeeded:(CGImageRef)cgimg
{
    bool isRetina = [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.0;
    if (isRetina) {
        return [UIImage imageWithCGImage:cgimg scale:2.0 orientation:UIImageOrientationUp];
    } else {
        return [UIImage imageWithCGImage:cgimg];
    }
}

- (UIImage*)takeScreenShot
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.window.bounds.size);
    [self.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)addBlur
{
    @try {
        self.vBlur = [[UIImageView alloc] initWithImage:[self blurryGPUImage:[self takeScreenShot] withBlurLevel:2 andPhases:4]];
        [self.window.rootViewController.view addSubview:self.vBlur];
        [self.window.rootViewController.view bringSubviewToFront:self.vBlur];
    }
    @catch (NSException*) {
        self.vBlur = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IPHONE_5 ? @"Splash5.png" : @"Splash.png")]];
    }
}

- (void)removeBlur
{
    if (self.vBlur) {
        [self.vBlur removeFromSuperview];
    }
    self.vBlur = nil;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iRoboDev" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iRoboDev.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Application scenario

- (void)getScenario
{
    if ([self.userProfile needToRegister])
    {
        [self firstTimeRegister];
        return;
    }
    
    if ([self.userProfile needToApprove])
    {
        [self approveProfile];
        return;
    }
    
    [self gotoWork];
}

- (void)firstTimeRegister
{
    _firstInitialization = NO;
    [self hideWait];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[RegisterViewController_iPhone alloc] initWithNibName:@"RegisterViewController_iPhone" bundle:nil]];
    [self.window setRootViewController:nc];
}

- (void)approveProfile
{
    _firstInitialization = NO;
    [self hideWait];
    if (!self.userProfile.phoneApproved)
    {
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[ApprovePhoneViewController_iPhone alloc] initWithNibName:@"ApprovePhoneViewController_iPhone" bundle:nil]];
        [self.window setRootViewController:nc];
    }
    else
    {
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:[[ApproveEMailViewController_iPhone alloc] initWithNibName:@"ApproveEMailViewController_iPhone" bundle:nil]];
        [self.window setRootViewController:nc];
    }
}

- (void)gotoWork
{
    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController_iPhone alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil]];
    
    UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:[[MenuViewController_iPhone alloc] initWithNibName:@"MenuViewController_iPhone" bundle:nil]];
    rearNavigationController.navigationBarHidden = YES;
    
    _revealViewController = [[SWRevealViewController alloc] initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
    _revealViewController.delegate = self;
    _revealViewController.rightViewController = [[MessagesViewController_iPhone alloc] initWithNibName:@"MessagesViewController_iPhone" bundle:nil];
    
    [self.window setRootViewController:_revealViewController];
    if (!_firstInitialization)
        [self showCheckPasswordView];
}

- (void)showCheckPasswordView
{
    if (![self.userProfile needToApprove] && ![self.userProfile needToRegister] && !_nowCheckingPassword)
    {
        NSDate *currentDate = [NSDate date];
        if (_backgroundDate == nil || (currentDate.timeIntervalSince1970 - _backgroundDate.timeIntervalSince1970) > _settings.passwordTimeout * 60)
        {
            if (_checkPasswordView_iPhone.view.superview != self.window.rootViewController.view)
                [self.window.rootViewController.view addSubview:_checkPasswordView_iPhone.view];
            [self.window.rootViewController.view bringSubviewToFront:_checkPasswordView_iPhone.view];
            if (_firstInitialization)
            {
                [self.window.rootViewController.view bringSubviewToFront:_waitingView_iPhone.view];
            }
        }
        else
        {
            if (_needToProcessLaunchURL)
                [self performSelector:@selector(processLaunchURL) withObject:nil afterDelay:.5];
        }
    }
    else
    {
        if (_needToProcessLaunchURL)
            [self performSelector:@selector(processLaunchURL) withObject:nil afterDelay:.5];
    }
}

- (void)processLaunchURL
{
    if (!_needToProcessLaunchURL) return;
    if (!_launchURL || _launchURL == nil) return;
    
    _needToProcessLaunchURL = NO;
    //Обрабатываем команду
    if ([[[_launchURL scheme] uppercaseString] isEqualToString:@"ROBOKASSA"]) {
        //Просто открылись и все
        if ([[[_launchURL host] uppercaseString] isEqualToString:@""]) {
            UINavigationController *frontNavigationController = (id)_revealViewController.frontViewController;
            if ( ![frontNavigationController.topViewController isKindOfClass:[MainViewController_iPhone class]] )
            {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController_iPhone alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil]];
                [_revealViewController pushFrontViewController:navigationController animated:NO];
            }
            return;
        }
    
        //Нужна оплата счета
        if ([[[_launchURL host] uppercaseString] isEqualToString:@"CHECK"]) {
            UINavigationController *frontNavigationController = (id)_revealViewController.frontViewController;
            if ( ![frontNavigationController.topViewController isKindOfClass:[MainViewController_iPhone class]] )
            {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController_iPhone alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil]];
                [_revealViewController pushFrontViewController:navigationController animated:NO];
            }
            NSString *prm = [_launchURL parameterValue:@"checkId"];
            if (prm && prm != nil)
            {
                [(MainViewController_iPhone *)frontNavigationController.topViewController payCheckById:[prm intValue]];
                return;
            }
            prm = [_launchURL parameterValue:@"OpKey"];
            if (prm && prm != nil)
            {
                [(MainViewController_iPhone *)frontNavigationController.topViewController payCheckByOpKey:prm];
                return;
            }
            return;
        }
    
        //Переходим в карты
        if ([[[_launchURL host] uppercaseString] isEqualToString:@"CARDS"]) {
            UINavigationController *frontNavigationController = (id)_revealViewController.frontViewController;
            if ( ![frontNavigationController.topViewController isKindOfClass:[CardsViewController_iPhone class]] )
            {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[CardsViewController_iPhone alloc] initWithNibName:@"CardsViewController_iPhone" bundle:nil showUnauthorizedCards:YES withFormType:CardsViewFormTypeFullView]];
                [_revealViewController pushFrontViewController:navigationController animated:NO];
            }
            return;
        }
    
        //Оплата благотворительности
        if ([[[_launchURL host] uppercaseString] isEqualToString:@"CHARITY"]) {
            UINavigationController *frontNavigationController = (id)_revealViewController.frontViewController;
            if ( ![frontNavigationController.topViewController isKindOfClass:[MainViewController_iPhone class]] )
            {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController_iPhone alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil]];
                [_revealViewController pushFrontViewController:navigationController animated:NO];
            }
            NSString *prm = [_launchURL parameterValue:@"CharityID"];
            if (prm && prm != nil)
            {
                [(MainViewController_iPhone *)frontNavigationController.topViewController payCharity:prm];
                return;
            }
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"URLCommand_Unsupported_Title", @"URLCommand_Unsupported_Title") message:NSLocalizedString(@"URLCommand_Unsupported_Message", @"URLCommand_Unsupported_Message") delegate:nil cancelButtonTitle:NSLocalizedString(@"Button_Continue", @"Button_Continue") otherButtonTitles:nil];
        [alert show];
    }
    if ([[[_launchURL scheme] uppercaseString] isEqualToString:@"CARD2CARD"]) {
        UINavigationController *frontNavigationController = (id)_revealViewController.frontViewController;
        if ( ![frontNavigationController.topViewController isKindOfClass:[MainViewController_iPhone class]] )
        {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[MainViewController_iPhone alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil]];
            [_revealViewController pushFrontViewController:navigationController animated:NO];
        }
        NSString *toCard = @"";
        if ([[[_launchURL host] uppercaseString] isEqualToString:@"TO_CARD"]) {
            toCard = [[_launchURL path] substringFromIndex:1];
        }
        [(MainViewController_iPhone *)frontNavigationController.topViewController c2cTransfer:toCard];
        return;
    }
}

- (void)applyScanedURL:(NSURL *)url
{
    if ([self applyLaunchURL:url])
        [self performSelector:@selector(processLaunchURL) withObject:nil afterDelay:.5];
}

#pragma mark CheckPasswordDelegate

- (void)passwordChecked:(UIViewController *)controller withResult:(BOOL)result
{
    if (!result) exit(0);
    [controller.view removeFromSuperview];
    if (_needToProcessLaunchURL)
        [self performSelector:@selector(processLaunchURL) withObject:nil afterDelay:.5];
}

@end
