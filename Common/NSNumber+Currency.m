//
//  NSNumber+Currency.m
//  iRobo
//
//  Created by Ivan Alekseev on 15.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "NSNumber+Currency.h"

@implementation NSNumber (CurrencyExtensions)

- (NSString *)numberWithCurrency
{
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithDecimal:[self decimalValue]];
    
    int rubls = [dn intValue];
    NSDecimalNumber *n = [dn decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:-rubls] decimalValue]]];
    n = [n decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:100] decimalValue]]];
    int cops = [n intValue];
    
    NSString *rs = [self currencyText:rubls :NSLocalizedString(@"rub1", @"") :NSLocalizedString(@"rub2", @"") :NSLocalizedString(@"rub5", @"")];
    NSString *cs = [self currencyText:cops :NSLocalizedString(@"cop1", @"") :NSLocalizedString(@"cop2", @"") :NSLocalizedString(@"cop5", @"")];
    
    return [NSString stringWithFormat:@"%i %@ %02i %@", rubls, rs, cops, cs];
}

- (NSString *)numberWithCurrencyShort
{
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithDecimal:[self decimalValue]];
    
    int rubls = [dn intValue];
    
    NSString *rs = [self currencyText:rubls :NSLocalizedString(@"rub1", @"") :NSLocalizedString(@"rub2", @"") :NSLocalizedString(@"rub5", @"")];
    
    return [NSString stringWithFormat:@"%i %@", rubls, rs];
}

- (NSString *)currencyText:(int)n :(NSString *)one :(NSString *)two :(NSString *)five
{
    int p = n % 100;
    if (p > 20)
        p = p %10;
    
    switch (p)
    {
        case 1:
            return one;
        case 2:
        case 3:
        case 4:
            return two;
        default:
            return five;
    }
}

@end
