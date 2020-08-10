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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation* location = [locations lastObject];
    self.currentLocation = location;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: location.coordinate.latitude longitude: location.coordinate.longitude zoom: self.zoomLevel];
    if ([self.mapView isHidden]){
        [self.mapView setHidden: NO];
        self.mapView.camera = camera;
    } else{
        [self.mapView animateToCameraPosition: camera];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.locationManager stopUpdatingLocation];
    NSLog(@"Error: %@", error);
}

- (void) createMapView{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: self.currentLocation.coordinate.latitude longitude: self.currentLocation.coordinate.longitude zoom: self.zoomLevel];
        self.mapView = [GMSMapView mapWithFrame: self.view.bounds camera: camera];
       self.mapView.settings.myLocationButton = YES;
       [self.mapView setMyLocationEnabled: YES];
       [self.view addSubview: self.mapView];
       [self.mapView setHidden: NO];
}

@end
