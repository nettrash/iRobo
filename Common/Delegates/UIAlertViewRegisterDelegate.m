//
//  UIAlertViewRegisterDelegate.m
//  iRobo
//
//  Created by Ivan Alekseev on 15.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "UIAlertViewRegisterDelegate.h"
#import "AppDelegate.h"

@implementation UIAlertViewRegisterDelegate

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1: { //Register
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            app.userProfile = [UserProfile load:app.managedObjectContext];
            [app getScenario];
            break;
        }
        default:
            break;
    }
}

@end
