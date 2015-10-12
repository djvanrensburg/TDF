//
//  CourseMapViewController.m
//  Golf Scorer
//
//  Created by DJ from iMac on 2015/07/30.
//  Copyright (c) 2015 DJ. All rights reserved.
//
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#import "CourseMapViewController.h"
#import <MapKit/MapKit.h>
#import "Constants.h"
@import CoreLocation;

@interface CourseMapViewController ()
@property MKMapView *mapView;
@property UILabel *distanceLB;
@property CLLocationManager *locationManager;
@property NSString *measurementSystem;
@property MKPinAnnotationView *blueDotView;
@property MKMapCamera *camera;
@property BOOL isPinching;
@property CLLocationDirection north;
@property BOOL initial;
@property BOOL isBusyZooming;
@property BOOL mapChanged;
@property BOOL settledOnZoomLevel;
@property MKCoordinateRegion originalRegion;
@end

@implementation CourseMapViewController


- (void)viewDidAppear:(BOOL)animated{
//    [NSTimer scheduledTimerWithTimeInterval:1.0  target:self selector:@selector(updateNorth) userInfo:nil repeats:YES];
}

//- (void) updateNorth{
//    if ([self.mapView respondsToSelector:@selector(camera)]) {
//        [self.camera setHeading:self.north];
//        [self.mapView setCamera:self.camera animated:YES];
//    }
//
//}

-(BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidLoad {
    self.mapChanged = NO;
    self.initial = YES;
    [super viewDidLoad];
    //phytagoras
//    float side = sqrt(self.view.frame.size.height*self.view.frame.size.height + self.view.frame.size.height*self.view.frame.size.height);
    float side = self.view.frame.size.height*self.view.frame.size.height;
//    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-side/2, self.view.frame.size.height/2-side/2, side, side)];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setDelegate:self];
    self.mapView.mapType = MKMapTypeSatellite;
    MKCoordinateRegion region;
    region.span = MKCoordinateSpanMake(0.003, 0.003); //Zoom distance
    self.originalRegion = region;
//    [self.mapView center];
    [self.mapView setRegion:region animated:NO];
    //zoom
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureCaptured:)];
    [pinch setDelegate:self];
    [pinch setDelaysTouchesBegan:YES];
    [self.mapView addGestureRecognizer:pinch];
    //drag
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCaptured:)];
    [pan setDelegate:self];
    [pan setDelaysTouchesBegan:YES];
    [self.mapView addGestureRecognizer:pan];

    [self.view addSubview:self.mapView];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        self.locationManager.headingFilter = kCLHeadingFilterNone;
        [self.locationManager startUpdatingHeading];
    }

    
    self.distanceLB = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 70.0, 100, 30)];
    NSLocale *locale = [NSLocale currentLocale];
    self.measurementSystem = [locale objectForKey: NSLocaleMeasurementSystem];
    self.distanceLB.text = @"0.0m";
    self.distanceLB.textColor = [UIColor whiteColor];
    self.distanceLB.textAlignment = NSTextAlignmentCenter;
    self.distanceLB.font = [UIFont fontWithName:mainFont size:25];
    [self.view addSubview:self.distanceLB];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    
    [self.mapView addGestureRecognizer:tapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return  YES;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return  YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Location Manager Delegate Methods

#pragma mark - MKMapViewDelegate Methods

//- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
//    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
//}
- (void)pinchGestureCaptured:(UIPinchGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateEnded){
//        self.isBusyZooming = NO;
        self.mapChanged = YES;
    }else{
//        self.isBusyZooming = YES;
    }
}

- (void)panGestureCaptured:(UIPanGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateEnded){
        self.mapChanged = YES;
    }
}

-(IBAction)recallibrate:(id)sender{    //center on blue dot
    self.initial = YES;
    self.mapChanged = NO;
    MKCoordinateRegion region;
    region.span = MKCoordinateSpanMake(0.003, 0.003); //Zoom distance
    CLLocationCoordinate2D bluedotPoint;// = [self.mapView convertPoint:self.blueDotView.center toCoordinateFromView:self.view];
    bluedotPoint.latitude = self.blueDotView.annotation.coordinate.latitude;
    bluedotPoint.longitude = self.blueDotView.annotation.coordinate.longitude;
    region.center = bluedotPoint;
    [self.mapView setRegion:region];
}

-(IBAction)foundTap:(UITapGestureRecognizer *)gestureRecognizer{
    
    //remove previous pins
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    CGPoint point = [gestureRecognizer locationInView:self.view];
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
    marker.coordinate = tapPoint;
    
    [self.mapView addAnnotation:marker];
    
    CLLocation *point1 = [[CLLocation alloc] initWithLatitude:tapPoint.latitude longitude:tapPoint.longitude];
//    CLLocation *myPoint = [[CLLocation alloc] initWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude];
    CLLocation *myPoint = [[CLLocation alloc] initWithLatitude:self.blueDotView.annotation.coordinate.latitude longitude:self.blueDotView.annotation.coordinate.longitude];
    
    CLLocationDistance dist = [point1 distanceFromLocation:myPoint];
    NSString* formattedNumber = [NSString stringWithFormat:@"%.02f", dist];
    self.distanceLB.text = [NSString stringWithFormat:@"%@%@",formattedNumber,@"m"];
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if (!userLocation || self.mapChanged)
        return;
    [self.mapView setCenterCoordinate:userLocation.location.coordinate];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    self.isBusyZooming = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    self.isBusyZooming = NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    if (!self.isBusyZooming) {
        self.mapView.camera.heading = (double)newHeading.magneticHeading;
    }
}

// An MKMapViewDelegate method. Use this to get a reference to the blue dot annotation view as soon as it gets added
- (void)mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views {
    
    for (MKAnnotationView *annotationView in views) {
        
        // Get the user location view, check for all of your custom annotation view classes here
        if (![annotationView isKindOfClass:[MKPinAnnotationView class]]){
            self.blueDotView = (MKPinAnnotationView *)annotationView;
            [self addViewportToBlueDotView];
            //            gotUsersLocationView = YES;
        }
    }
}

// Adds the 'viewPortView' to the annotation view. Assumes we have a reference to the annotation view. Call this before you start listening to for heading events.
- (void)addViewportToBlueDotView {
    if (self.blueDotView == nil) {
        // No reference to the view, can't do anything
        return;
    }
    UIImageView *directionView;
    if (directionView == nil) {
        directionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowWhite.png"]];
    }
    
    [self.blueDotView addSubview:directionView];
    [self.blueDotView sendSubviewToBack:directionView];
    
    directionView.frame = CGRectMake((-1 * directionView.frame.size.width/2) + self.blueDotView.frame.size.width/2,
                                         (-1 * directionView.frame.size.height/2) + self.blueDotView.frame.size.height/2 - 15,
                                         directionView.frame.size.width, directionView.frame.size.height);
}

@end
