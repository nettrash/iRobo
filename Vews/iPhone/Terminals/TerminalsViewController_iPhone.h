//
//  TerminalsViewController_iPhone.h
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TerminalsViewController_iPhone : UIViewController <MKMapViewDelegate, UISearchBarDelegate>
{
    BOOL _firstZoom;
}

@end
