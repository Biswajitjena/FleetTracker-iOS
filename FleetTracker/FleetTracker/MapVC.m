//
//  MapVC.m
//  FleetTracker
//
//  Created by Theappfathers on 09/02/23.
//

#import "MapVC.h"

@interface MapVC ()

@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;


    self.locationManager.distanceFilter = 1000;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
  
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        self.locationManager.headingFilter = 5;
       [self.locationManager startUpdatingHeading];
    }
    
    if ([CLLocationManager locationServicesEnabled] )
    {
        if (self.locationManager == nil )
        {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        }
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
   // here we get the current location
    MKCoordinateRegion region;
    CLLocationCoordinate2D location;
    location.latitude = self.currentLocation.coordinate.latitude;
    location.longitude = self.currentLocation.coordinate.longitude;
    region.center = location;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];


    self.lblLocation.text = [NSString stringWithFormat:@"%f, %f", self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude];
    self.lblSpeed.text = [NSString stringWithFormat:@"%f", self.currentLocation.speed];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {

    self.lblHeading.text = [NSString stringWithFormat:@"%f",newHeading.headingAccuracy];
}



@end
