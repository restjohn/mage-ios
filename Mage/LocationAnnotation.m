//
//  LocationAnnotation.m
//  Mage
//
//  Created by Billy Newman on 6/24/14.
//

#import "LocationAnnotation.h"
#import "GeoPoint.h"
#import "User+helper.h"

@implementation LocationAnnotation

-(id) initWithLocation:(Location *) location inManagedObjectContext: (NSManagedObjectContext *) context {
	if ((self = [super init])) {
        _coordinate = ((GeoPoint *) location.geometry).location.coordinate;
		_timestamp = location.timestamp;
		
		User *user = [User fetchUserForId:location.userId inManagedObjectContext:context];
		_title = user.name;
		_subtitle = user.username;
    }
		
    return self;
}

-(void) setCoordinate:(CLLocationCoordinate2D) coordinate {
	_coordinate = coordinate;
}

@end
