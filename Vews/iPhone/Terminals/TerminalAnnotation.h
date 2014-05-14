//
//  TerminalAnnotation.h
//  iRobo
//
//  Created by Ivan Alekseev on 10.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "svcTerminal.h"

@interface TerminalAnnotation : NSObject <MKAnnotation>

@property (nonatomic, retain) svcTerminal *terminal;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

+ (id)annotationWithTerminal:(svcTerminal *)terminal;

@end
