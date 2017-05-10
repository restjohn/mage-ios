//
//  Locations.h
//  MAGE
//
//

#import <CoreData/CoreData.h>
#import "ManagedObjectContextHolder.h"
#import "User.h"

@interface Locations : NSObject

@property (nonatomic, strong) id<NSFetchedResultsControllerDelegate> delegate;
@property(nonatomic, strong)  NSFetchedResultsController *fetchedResultsController;

+ (id) locationsForAllUsers;
+ (id) locationsForUser:(User *) user;

+ (BOOL) getHideInactiveFilter;
+ (void) setHideInactivedFilter:(BOOL) filter;


- (id) initWithFetchedResultsController:(NSFetchedResultsController *) fetchedResultsController;

@end
