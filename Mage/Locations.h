//
//  Locations.h
//  MAGE
//
//  Created by Dan Barela on 9/16/14.
//  Copyright (c) 2014 National Geospatial Intelligence Agency. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ManagedObjectContextHolder.h"
#import "User+helper.h"

@interface Locations : NSObject

@property(nonatomic, strong)  NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, assign) id<NSFetchedResultsControllerDelegate> delegate;

+ (id) locationsForAllUsers;
+ (id) locationsForUser:(User *) user;


- (id) initWithFetchedResultsController:(NSFetchedResultsController *) fetchedResultsController;

@end
