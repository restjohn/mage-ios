//
//  MageRootViewController_ipad.m
//  MAGE
//
//  Created by William Newman on 9/19/14.
//  Copyright (c) 2014 National Geospatial Intelligence Agency. All rights reserved.
//

#import "MageRootViewController_ipad.h"

#import "MageSplitViewController.h"
#import <HttpManager.h>
#import "User+helper.h"

@interface MageRootViewController_ipad () <UISplitViewControllerDelegate>

@end

@implementation MageRootViewController_ipad

- (void) viewDidLoad {
    [self startServices];
    
    MageSplitViewController *splitViewController = [self.viewControllers firstObject];
    splitViewController.delegate = self;
    
    [super viewDidLoad];
}

- (void) startServices {
    _locationService = [[LocationService alloc] initWithManagedObjectContext:self.contextHolder.managedObjectContext];
    [_locationService start];
    
    NSOperation *usersPullOp = [User operationToFetchUsersWithManagedObjectContext:self.contextHolder.managedObjectContext];
    NSOperation *startLocationFetchOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"done with intial user fetch, lets start the location fetch service");
        [self.fetchServicesHolder.locationFetchService start];
    }];
    
    NSOperation *startObservationFetchOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"done with intial user fetch, lets start the observation fetch service");
        [self.fetchServicesHolder.observationFetchService start];
    }];
    
    [startObservationFetchOp addDependency:usersPullOp];
    [startLocationFetchOp addDependency:usersPullOp];
    
    // Add the operations to the queue
    [[HttpManager singleton].manager.operationQueue addOperations:@[usersPullOp, startObservationFetchOp, startLocationFetchOp] waitUntilFinished:NO];
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
//    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
//        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//        return YES;
//    } else {
//        return NO;
//    }
    return YES;
}

@end
