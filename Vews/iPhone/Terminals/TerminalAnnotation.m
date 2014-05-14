//
//  TerminalAnnotation.m
//  iRobo
//
//  Created by Ivan Alekseev on 10.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "TerminalAnnotation.h"

@implementation TerminalAnnotation

@synthesize terminal = _terminal;
@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

+ (id)annotationWithTerminal:(svcTerminal *)terminal
{
    TerminalAnnotation *retVal = [TerminalAnnotation alloc];
    retVal.terminal = terminal;
    retVal.title = terminal.terminal_City;
    retVal.subtitle = terminal.terminal_Address;
    retVal.coordinate = CLLocationCoordinate2DMake([terminal.terminal_Latitude doubleValue], [terminal.terminal_Longtitude doubleValue]);
    return retVal;
}

#pragma mark MKAnnotation

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = CLLocationCoordinate2DMake(newCoordinate.latitude, newCoordinate.longitude);
}

@end
