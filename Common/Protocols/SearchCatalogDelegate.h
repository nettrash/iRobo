//
//  SearchCatalogDelegate.h
//  iRobo
//
//  Created by Ivan Alekseev on 08.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "svcTopCurrency.h"

#ifndef iRobo_SearchCatalogDelegate_h
#define iRobo_SearchCatalogDelegate_h

@protocol SearchCatalogDelegate

- (void)searchResult:(UIViewController *)controller withCurrency:(svcTopCurrency *)currency;

@end

#endif
