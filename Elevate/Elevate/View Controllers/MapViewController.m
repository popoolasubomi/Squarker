//
//  MapViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 8/10/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic) float zoomLevel;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) getCurrentLocation{
    self.locationManager = [[CLLocationManager alloc] init];
    self.currentLocation = [[CLLocation alloc] init];
    self.mapView = [[GMSMapView alloc] init];
    self.zoomLevel = 15.0;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
}

@end
