//
//  ObservationAnnotation.m
//  Mage
//
//

#import "ObservationAnnotation.h"
#import "NSDate+DateTools.h"
#import "ObservationImage.h"
#import "WKBGeometryUtils.h"
#import "MapShapeObservation.h"

@interface ObservationAnnotation ()

@property (nonatomic) BOOL point;

@end

@implementation ObservationAnnotation

-(id) initWithObservation:(Observation *) observation {
    WKBGeometry *geometry = [observation getGeometry];
    WKBPoint *point = [WKBGeometryUtils centroidOfGeometry:geometry];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([point.y doubleValue], [point.x doubleValue]);
    self.point = YES;
    return [self initWithObservation:observation andLocation:location];
}

- (id)initWithObservation:(Observation *) observation andLocation:(CLLocationCoordinate2D) location{
    if ((self = [super init])) {
        _observation = observation;
        [self setCoordinate:location];
        [self setTitle:[observation.properties objectForKey:@"type"]];
        if (self.title == nil) {
            [self setTitle:@"Observation"];
        }
        [self setSubtitle:observation.timestamp.timeAgoSinceNow];
    }
    [self setAccessibilityLabel:@"Observation Annotation"];
    [self setAccessibilityValue:@"Observation Annotation"];
    return self;
}

- (MKAnnotationView *) viewForAnnotationOnMapView: (MKMapView *) mapView {
    UIImage *image = [ObservationImage imageForObservation:self.observation inMapView:mapView];
    NSString *accessibilityIdentifier = self.point ? [image accessibilityIdentifier] : NSStringFromClass([MapShapeObservation class]);
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:accessibilityIdentifier];
    
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:accessibilityIdentifier];
        annotationView.enabled = YES;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        rightButton.tintColor = [UIColor colorWithRed:17.0/255.0 green:84.0/255.0 blue:164.0/255.0 alpha:1.0];
        annotationView.rightCalloutAccessoryView = rightButton;
        if(self.point){
            annotationView.image = image;
            annotationView.centerOffset = CGPointMake(0, -(annotationView.image.size.height/2.0f));
        }else{
            annotationView.image = nil;
            annotationView.centerOffset = CGPointMake(0, 0);
        }
    } else {
        annotationView.annotation = self;
    }
    [annotationView setAccessibilityLabel:@"Observation"];
    [annotationView setAccessibilityValue:@"Observation"];
    return annotationView;
}

@end
