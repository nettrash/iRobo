//
//  CardsViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 15.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enums.h"
#import "CardsViewControllerDelegate.h"
#import "AddCardDelegate.h"
#import "ActivityProtocols.h"

@interface CardsViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, CardsViewControllerDelegate, AddCardViewControllerDelegate, ActivityResultDelegate>
{
    NSMutableArray *_cardsOCEAN;
    NSMutableArray *_cardsVIRTUAL;
    NSMutableArray *_cardsOTHER;
    NSMutableArray *_cardsUnAuthorized;
    NSMutableArray *_cards;
    NSArray *_activities;
    BOOL _showUnAuthorizedCards;
    CardsViewFormType _formType;
    NSIndexPath *_selectedIndexPath;
}

@property (nonatomic, retain) id<CardsViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil showUnauthorizedCards:(BOOL)bShowUnAuthorizedCards withFormType:(CardsViewFormType)formType;

@end
