//
//  LocalCard.h
//  iRobo
//
//  Created by Ivan Alekseev on 16.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalCard : NSManagedObject

@property (nonatomic, retain) NSNumber * card_Id;
@property (nonatomic, retain) NSString * cvc;

@end
