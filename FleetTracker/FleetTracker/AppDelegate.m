//
//  AppDelegate.m
//  FleetTracker
//
//  Created by Theappfathers on 31/12/22.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "GCDAsyncUdpSocket.h"
#import "DBmanager.h"
#import "DataViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <sys/socket.h>
#import <net/if_dl.h>
#import <ifaddrs.h>
#import <sys/xattr.h>
#define IFT_ETHER 0x6
#include <stdio.h>
#include <arpa/inet.h>
#define TIME_INTERVAL_IDEAL 3600
#define TIME_INTERVAL_MOVING 30

@interface AppDelegate ()<CLLocationManagerDelegate>
{
    float head;
    int locationUpdateInterval;
    int locationTimer;
    NSString *heading;
    NSTimer *timer;
//    UIBackgroundTaskIdentifier *bgTask;
    __block UIBackgroundTaskIdentifier bgTask;
    NSString *macadd;
    NSString *locationlatlong;
    NSString *datetime;
    NSString *mode;
}
@property (nonatomic, strong) DBmanager *dbmanager;
@end

@implementation AppDelegate

#pragma mark - Delegate Method
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
                
    
 
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    locationTimer = 0;
    heading= @"0";

    [self startLocationManager];
    [self startMotionAndFitness];
    [self startMotionActivityManager];
    
    UIAlertView * alert;
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            [self.locationManager startMonitoringSignificantLocationChanges];
            //[self startLocationManager];
            //[self startSignificantLocation];
            
        }
    }

    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self.locationManager
                                           selector:@selector(startUpdatingLocation)
                                           userInfo:nil
                                            repeats:YES];
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground---------------");
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate----------");
}


#pragma mark - Location Service
-(void) startLocationManager{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter=kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    
    //get heading
    if ([CLLocationManager headingAvailable]) {
        
        self.locationManager.headingFilter = 0.5;
        //self.locationManager.headingFilter = kCLHeadingFilterNone;
        [self.locationManager startUpdatingHeading];
        NSLog(@"heading call");
    }
    
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
    if(IS_OS_9_OR_LATER){
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    [self changeAccuracy];
    [self.locationManager startUpdatingLocation];
   

    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"-------------didUpdateLocations---------");
    self.location = [locations lastObject];
    NSLog(@"location:%@",self.location);
    //[self.locationManager startUpdatingLocation];
      [self setTimer];
    //[self getsignalstrength];
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager{
    NSLog(@"locationManagerDidPauseLocationUpdates--------");
    [self startLocationManager];
}
-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager{
    NSLog(@"locationManagerDidResumeLocationUpdates----------");
    [self startLocationManager];
}


- (void) changeAccuracy {
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
}
#pragma mark - Other Helping Method
-(void)getsignalstrength
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"]valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]])
        {
            dataNetworkItemView = subview;
            break;
        }
    }
//    int signalStrength = [[dataNetworkItemView valueForKey:@"signalStrengthRaw"] intValue];
    //NSLog(@"signal %d", signalStrength);

}

-(void) setTimer{

    //Speed
    NSString *speed=[NSString stringWithFormat:@"%f", self.location.speed];
    float speedInFloat = [speed floatValue];
   // float speed_mph= speedInFloat*2.236936;
    
    if(speedInFloat > 0.00){
        
        if(locationTimer > TIME_INTERVAL_MOVING){
            locationTimer = 0;
        }
        
        locationUpdateInterval = TIME_INTERVAL_MOVING;
        if(locationTimer == locationUpdateInterval){
            [self connectserver:@"4003"];
            locationTimer = 0;
        }else{
            locationTimer = locationTimer + 1;
        }
    }else{
        // Device is not moving. IDEAL Device
        
        if(locationTimer > TIME_INTERVAL_IDEAL){
            locationTimer = 0;
        }
        locationUpdateInterval = TIME_INTERVAL_IDEAL;
        if(locationTimer == locationUpdateInterval){
            [self connectserver:@"4004"];
            
            locationTimer = 0;
            
            
        }else{
            locationTimer = locationTimer + 1;
            NSLog(@"locationTimer %d", locationTimer);
        }
    }
}

//-(void) saveLocationInDB:(NSString *)latitude andlongitude:(NSString *) longitude andSpeed:(NSString *)speed andDate:(NSString *)date addTime:(NSString *) time adddeviceState:(NSString *) devicestatus{
-(void) saveLocationInDB:(NSString *)location andtime:(NSString *)time andSpeed:(NSString *)speed andType:(NSString *)type {

    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{

        [[UIApplication sharedApplication] endBackgroundTask:self->bgTask];

        self->bgTask = UIBackgroundTaskInvalid;
    }];
    
    //Start background method to send data to server. It is neccessary to integrate server code between background method starts and Ends.
//    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
//    }];

    
    self.dbmanager = [[DBmanager alloc] initWithDatabaseFilename:@"FleetData.db"];
    
    // Prepare the INSERT query string.
    NSString *query = [NSString stringWithFormat:@"insert into locationdetail values(null, '%@','%@','%@','%@')",location,time,speed,type];
    // Execute the query.
    [self.dbmanager executeQuery:query];
    // If the query was successfully executed then pop the view controller.
    if (self.dbmanager.affectedRows != 0) {
//        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbmanager.affectedRows);
    }
    
    //Background task complete
    if(self->bgTask != UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask:self->bgTask];
        self->bgTask = UIBackgroundTaskInvalid;
    }
}
//delegate heading method

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
//    if (newHeading.headingAccuracy < 0)
//        return;
//
//    // Use the true heading if it is valid.
//    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
//                                       newHeading.trueHeading : newHeading.magneticHeading);
//    heading = [NSString stringWithFormat:@"%.1f", newHeading.trueHeading];
//    NSLog(@"truehead:%f",heading);
    //double head;
    head= manager.heading.trueHeading;
   
   // NSLog(@"Heading: %.1f", head);
}

#pragma mark - UDP Server

-(void)connectserver:(NSString *)eventCode {
    
    //Start background method to send data to server. It is neccessary to integrate server code between background method starts and Ends.
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self->bgTask];
    }];
    
    NSString *speed=[NSString stringWithFormat:@"%f", self.location.speed];
    float speedInFloat = [speed floatValue];
    NSString *longi=[NSString stringWithFormat:@"%0.5f", self.location.coordinate.longitude];
    NSString *lati=[NSString stringWithFormat:@"%0.5f", self.location.coordinate.latitude];
    NSString *alti=[NSString stringWithFormat:@"%0.1f", self.location.altitude];
    float speed_mph= speedInFloat*2.236936;
    if(speed_mph < 0){
        speed_mph = 0;
    }
    //battery level
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    double batLeft = (float)[myDevice batteryLevel] * 100;
//    NSString *batteryVoltage = [NSString stringWithFormat:@"%.1d",(int)batLeft];
    
    //Get Date
    NSDate *todayDate = [NSDate date]; // get today date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    [dateFormatter setDateFormat:@"YYYY/MM/dd"]; //Here we can set the format which we need
    NSString *convertedDateString = [dateFormatter stringFromDate:todayDate];// here convert date in
    
    //Get Accuracy
    float ac=self.location.horizontalAccuracy / 5.0;
    NSString *accuracy=[NSString stringWithFormat:@"%0.0f",ac];
    // Get Current time
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    dateFormatter.dateFormat = @"HH:mm:ss";
    
//    NSLog(@"The Current Time is:%@",[dateFormatter stringFromDate:todayDate]);
//    NSLog(@"Battery level:%.f",batLeft);
//    NSLog(@"Today formatted date is:%@",convertedDateString);
//    NSLog(@"SpeedMPH :%0.1f",speed_mph);
//    NSLog(@"AppDelegate :Longitude: %@",longi);
//    NSLog(@"AppDelegate :Latitude: %@",lati);
//    NSLog(@"Altitude :%@",alti);
//    NSLog(@"Horizontal Accuracy:%@",accuracy);
//    NSLog(@"Heading: %.1f", head);
    
    locationlatlong=[NSString stringWithFormat:@"%@,%@",lati,longi];
    NSString *speedinstring = [NSString stringWithFormat:@"%.1f mph",speed_mph];
    datetime=[NSString stringWithFormat:@"%@ %@",convertedDateString,[dateFormatter stringFromDate:todayDate]];
    
    if([heading isEqualToString:[NSNull null]]){
        heading = @"0";
    }
    
    NSString *IG;
    if([eventCode isEqualToString:@"4004"]){
        IG = @"0";
        mode=@"Ideal";
    }else{
        IG = @"1";
        mode=@"Moving";
    }
    
    //get macaddress
    
    macadd=[[NSUserDefaults standardUserDefaults] objectForKey:@"MACADDRESS"];
    
    if([macadd length] != 0)
    {
        NSString *finalCode =[NSString stringWithFormat:@"$$%@,%@,%@,%@,%@,%@,%@,%.1f,%.1f,%@,%.1f,0,0,0,0,0,0,0,0,0,0,%@##",macadd,eventCode,convertedDateString,[dateFormatter stringFromDate:todayDate],lati,longi,alti,speed_mph,head,accuracy,batLeft,IG];
        NSLog(@"code string:%@",finalCode);
        
    
        [self sendDataToServer:finalCode];
            
            //import Database
        [self saveLocationInDB:locationlatlong  andtime:datetime andSpeed:speedinstring andType:mode];
       
    }
    
    //Background task complete
    if(bgTask != UIBackgroundTaskInvalid){
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}


-(void) sendDataToServer: (NSString *)message{
    
    GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![udpSocket bindToPort:0 error:&error])
    {
       // NSLog(@"****************************************Error binding: %@",error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
       // NSLog(@"******************************************Error receiving: %@", error);
        return;
    }
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
  //  [udpSocket sendData:data toHost:@"182.70.116.121" port:8080 withTimeout:5000 tag:1];
    [udpSocket sendData:data toHost:@"144.126.154.179" port:34016 withTimeout:5000 tag:1];
    [udpSocket closeAfterSending];
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
    NSLog(@"did send data with tag: %ld",tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
    NSLog(@"did not send data with tag : %ld : %@",tag, error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        NSLog(@"MSG RECEIVED FROM SERVER: %@",msg);
    }
    else
    {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        NSLog(@"RECV: Unknown message from: %@:%hu",host, port);
    }
}

#pragma  mark - CMMotion Events

-(void)startMotionAndFitness{
    CMMotionManager *motionManager = [CMMotionManager new];
    BOOL canUseDeviceMotion = motionManager.deviceMotionAvailable;
    if(canUseDeviceMotion){
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMAccelerometerData *accelerometerData,NSError *error){
            if(!error){
                NSLog(@"Accelerometer data is available:%@",[accelerometerData description]);
            }
        }];
    }
}

-(void)startMotionActivityManager{
    
    CMMotionActivityManager *motionActivityManager = [CMMotionActivityManager new];
    BOOL isActivitymanagerAvaialble = [CMMotionActivityManager isActivityAvailable];
    
    if(isActivitymanagerAvaialble){
        [motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMMotionActivity *activity){
            
            if(activity.confidence == CMMotionActivityConfidenceHigh){
                NSLog(@"CMMotionActivityConfidenceHigh");
                NSString *userAcivity = @"Not Defined";
                if (activity.stationary){
                    userAcivity = @"Sitting, doing nothing";
                    NSLog(@"Sitting, doing nothing");
                } else if (activity.running){
                    userAcivity = @"Active Running";
                    NSLog(@"Active! Running!");
                } else if (activity.automotive){
                    userAcivity = @"Driving";
                    NSLog(@"Driving along!");
                } else if (activity.walking){
                    userAcivity = @"Walking";
                    NSLog(@"Strolling round the city..");
                }
            }
        }];
    }
}




@end

