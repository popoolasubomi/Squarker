//
//  MapViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 8/10/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "MapViewController.h"
#import "Parse/Parse.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic) float zoomLevel;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNumber *some = [PFUser.currentUser objectForKey: @"Longitude"];
    NSLog(@"%f", some.doubleValue);
    [self getCurrentLocation];
    [self createMapView];
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
    NSNumber *longitude = [NSNumber numberWithDouble: self.currentLocation.coordinate.longitude];
    NSNumber *latitude = [NSNumber numberWithDouble: self.currentLocation.coordinate.latitude];
    [PFUser.currentUser setObject: longitude forKey: @"Longitude"];
    [PFUser.currentUser setObject: latitude forKey: @"Latitude"];
    [PFUser.currentUser saveInBackground];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.locationManager stopUpdatingLocation];
    NSLog(@"Error: %@", error);
}

-(void) backButtonClicked:(UIButton*)sender{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) createMapView{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: self.currentLocation.coordinate.latitude longitude: self.currentLocation.coordinate.longitude zoom: self.zoomLevel];
        self.mapView = [GMSMapView mapWithFrame: self.view.bounds camera: camera];
       self.mapView.settings.myLocationButton = YES;
       [self.mapView setMyLocationEnabled: YES];
       [self.view addSubview: self.mapView];
       [self.mapView setHidden: NO];
    
    self.backButton = [UIButton buttonWithType: UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(20.0,  40.0, 50.0, 30.0);
    [self.backButton setTitle:@"Back" forState: UIControlStateNormal];
    [self.backButton setTitleColor: [UIColor blueColor] forState: UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton sizeToFit];
    [self.view addSubview: self.backButton];
}


@end
