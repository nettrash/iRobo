//
//  UIImage+QR.h
//  iRobo
//
//  Created by Ivan Alekseev on 14.07.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QR)

+ (UIImage *)quickResponseImageForString:(NSString *)dataString withDimension:(int)imageWidth;

@end
