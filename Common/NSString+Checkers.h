//
//  NSString+Checkers.h
//  iRobo
//
//  Created by Ivan Alekseev on 12.05.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Checkers)

- (BOOL)isRobodQRCommand;
- (BOOL)isVCARD;
- (BOOL)isURL;
- (BOOL)isHTML;
- (NSString *)HTMLWithSystemFont;
- (BOOL)isPossibleMoscowGKU;
- (BOOL)isPossibleMGTS;
- (BOOL)isPossibleMosenergosbut;
- (BOOL)isPossibleGIBDD;

@end
