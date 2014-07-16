//
//  MainViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 08.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayViewControllerDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "SearchCatalogDelegate.h"
#import "ScanViewControllerDelegate.h"
#import "UIAlertWithInternetSearchDelegate.h"
#import "UIAlertWithOpenURLDelegate.h"
#import <AddressBookUI/AddressBookUI.h>
#import "CardsViewControllerDelegate.h"

@interface MainViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, PayViewControllerDelegate, MFMailComposeViewControllerDelegate, SearchCatalogDelegate, ScanViewControllerDelegate, ABUnknownPersonViewControllerDelegate, CardsViewControllerDelegate> {
    NSArray *_checks;
    NSArray *_topCatalog;
    BOOL _checksRefreshing;
    BOOL _topCatalogRefreshing;
    BOOL _firstInitialized;
    UIAlertWithInternetSearchDelegate *_internetSearchDelegate;
    UIAlertWithOpenURLDelegate *_openURLDelegate;
}

- (void)payCheckById:(int)check_Id;
- (void)payCheckByOpKey:(NSString *)OpKey;
- (void)payCharity:(NSString *)CharityID;
- (void)c2cTransfer:(NSString *)toCard;

@end

