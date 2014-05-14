//
//  NSNumber+Currency.h
//  iRobo
//
//  Created by Ivan Alekseev on 15.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (CurrencyExtensions)

- (NSString *)numberWithCurrency;
- (NSString *)numberWithCurrencyShort;

@end
