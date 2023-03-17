//
//  MapVC.h
//  FleetTracker
//
//  Created by Theappfathers on 09/02/23.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface MapVC : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UILabel *lblLocation;
@property (nonatomic, retain) IBOutlet UILabel *lblSpeed;
@property (nonatomic, retain) IBOutlet UILabel *lblHeading;

@end

NS_ASSUME_NONNULL_END
