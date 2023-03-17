//
//  AppDelegate.h
//  FleetTracker
//
//  Created by Theappfathers on 31/12/22.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DBmanager.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, strong) NSString *GOOGLE_MAP_API_KEY;
@end

