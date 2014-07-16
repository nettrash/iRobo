//
//  AppDelegate.h
//  iRoboDev
//
//  Created by Ivan Alekseev on 30.03.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"
#import "GPUImage.h"
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#import "WaitingViewController_iPhone.h"
#import "CheckPasswordViewController_iPhone.h"
#import "SWRevealViewController.h"
#import "NoInternetConnectionViewController_iPhone.h"
#import "AppSettings.h"
#import "UIAlertViewRegisterDelegate.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@class Reachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate, SWRevealViewControllerDelegate, CheckPasswordDelegate>
{
    WaitingViewController_iPhone *_waitingView_iPhone;
    CheckPasswordViewController_iPhone *_checkPasswordView_iPhone;
    SWRevealViewController *_revealViewController;
    NoInternetConnectionViewController_iPhone *_noInternetConnectionView_iPhone;
    
    BOOL _nowWaiting;
    BOOL _nowCheckingPassword;
    BOOL _netIsWiFi;
    BOOL _noInternet;
    BOOL _fromBackground;
    BOOL _firstInitialization;
    
    Reachability *_internetReach;
    AppSettings *_settings;
    
    NSDate *_backgroundDate;
    
    NSDictionary *_audioProfile;
    
    NSURL *_launchURL;
    BOOL _needToProcessLaunchURL;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UIImageView *vBlur;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) UserProfile *userProfile;

@property (nonatomic, strong) UIAlertViewRegisterDelegate *registerAlertDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


- (UIImage*)blur:(UIImage*)theImage;
- (UIImage*)blurryGPUImage:(UIImage *)image withBlurLevel:(NSInteger)blur andPhases:(NSInteger)phases;
- (UIImage*)scaleIfNeeded:(CGImageRef)cgimg;
- (UIImage*)takeScreenShot;

- (void)showWait:(NSString *)message;
- (void)hideWait;

- (void)playSound:(NSURL *)audioURL;
- (void)stopSound;
- (void)personVoiceForGroup:(NSString *)group andAction:(NSString *)action;

- (void)getScenario;
- (void)firstTimeRegister;
- (void)approveProfile;
- (void)gotoWork;

- (NSString *)PlatformName;
- (NSString *)DeviceName;

- (void)playProfileSound;

- (void)applyScanedURL:(NSURL *)url;

- (void)firstTimeInitializationComplete;

- (void)demoModeAlert;

@end
