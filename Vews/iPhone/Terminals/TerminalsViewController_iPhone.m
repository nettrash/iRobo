//
//  TerminalsViewController_iPhone.m
//  iRobo
//
//  Created by Ivan Alekseev on 09.04.14.
//  Copyright (c) 2014 ROBOKASSA. All rights reserved.
//

#import "TerminalsViewController_iPhone.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "svcWSMobileBANK.h"
#import "svcWSResponse.h"
#import "svcTerminal.h"
#import "TerminalAnnotation.h"
#import "SWRevealViewController.h"

@interface TerminalsViewController_iPhone ()

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) UIActivityIndicatorView *aivWait;

@end

@implementation TerminalsViewController_iPhone

@synthesize map = _map;
@synthesize aivWait = _aivWait;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstZoom = YES;
        self.navigationItem.title = NSLocalizedString(@"Terminals_Title", @"Terminals_Title");
        SWRevealViewController *revealViewController = [self revealViewController];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"] style:UIBarButtonItemStylePlain target:revealViewController action:@selector(revealToggle:)];
        self.aivWait = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.aivWait.hidesWhenStopped = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.aivWait];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.map.showsPointsOfInterest = YES;
    self.map.showsBuildings = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTerminals
{
    [self.aivWait startAnimating];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    
    NSDecimalNumber *latitude = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:(double)self.map.userLocation.coordinate.latitude] decimalValue]];
    NSDecimalNumber *longitude = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:(double)self.map.userLocation.coordinate.longitude] decimalValue]];
    NSDecimalNumber *delta = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:0.01f] decimalValue]];
    
    [svc GetTerminalsNearCoord:self action:@selector(getTerminalsHandler:) UNIQUE:[app.userProfile uid] Latitude:latitude Longtitude:longitude Delta:delta];
}

- (void)updateTerminalsWithDelta
{
    [self.aivWait startAnimating];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svcWSMobileBANK *svc = [svcWSMobileBANK service];
    svc.logging = YES;
    
    NSDecimalNumber *latitude = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:(double)self.map.region.center.latitude] decimalValue]];
    NSDecimalNumber *longitude = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:(double)self.map.region.center.longitude] decimalValue]];
    NSDecimalNumber *delta = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:0.01f] decimalValue]];

    if (self.map.region.span.latitudeDelta > [delta doubleValue] && self.map.region.span.latitudeDelta < 1)
        delta = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:self.map.region.span.latitudeDelta] decimalValue]];
    
    if (self.map.region.span.longitudeDelta > [delta doubleValue] && self.map.region.span.longitudeDelta < 1)
        delta = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:self.map.region.span.longitudeDelta] decimalValue]];
    
    [svc GetTerminalsNearCoord:self action:@selector(getTerminalsHandler:) UNIQUE:[app.userProfile uid] Latitude:latitude Longtitude:longitude Delta:delta];
}

- (void)getTerminalsHandler:(id)response
{
    [self.aivWait stopAnimating];
    if ([response isKindOfClass:[svcWSResponse class]])
    {
        svcWSResponse *wsResponse = (svcWSResponse *)response;
        if (wsResponse.result)
        {
            [self.map removeAnnotations:self.map.annotations];
            if (wsResponse.terminals != nil && [wsResponse.terminals count] > 0)
            {
                [self.map removeAnnotations:self.map.annotations];
                for (svcTerminal *t in wsResponse.terminals)
                {
                    if ([t.terminal_Type isEqualToString:@"OCEANTerminal"])
                    {
                        TerminalAnnotation *a = [TerminalAnnotation annotationWithTerminal:t];
                        [self.map addAnnotation:a];
                    }
                }
            }
        }
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (_firstZoom) {
        MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
        region.center.latitude = userLocation.coordinate.latitude;
        region.center.longitude = userLocation.coordinate.longitude;
        region.span.longitudeDelta = 0.01f;
        region.span.latitudeDelta = 0.01f;
        [mapView setRegion:region animated:YES];
        userLocation.title = NSLocalizedString(@"UserLocation_Title", @"UserLocation_Title");
        _firstZoom = NO;
        [self performSelector:@selector(updateTerminals) withObject:nil afterDelay:.1];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self updateTerminalsWithDelta];
}

#pragma mark UISearchBarDelegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:theSearchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil)
        {
            if (placemarks != nil && [placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                MKCoordinateRegion region = MKCoordinateRegionMake(placemark.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
                [self.map setRegion:region animated:YES];
                [self updateTerminalsWithDelta];
            }
        }
    }];
}

@end
