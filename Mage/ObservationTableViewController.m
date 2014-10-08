//
//  ObservationsViewController.m
//  Mage
//
//  Created by Dan Barela on 4/29/14.
//  Copyright (c) 2014 Dan Barela. All rights reserved.
//

#import "ObservationTableViewController.h"
#import "ObservationTableViewCell.h"
#import <Observation.h>
#import "ObservationViewController.h"
#import "MageRootViewController.h"

@interface ObservationTableViewController ()
@property(nonatomic, strong) IBOutlet UIRefreshControl *refreshControl;
@end

@implementation ObservationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.observationDataStore startFetchControllerWithManagedObjectContext:self.contextHolder.managedObjectContext];
    
    [self.refreshControl addTarget:self
                            action:@selector(refreshObservations)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) prepareForSegue:(UIStoryboardSegue *) segue sender:(id) sender {
    if ([[segue identifier] isEqualToString:@"DisplayObservationSegue"]) {
        id destination = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		Observation *observation = [self.observationDataStore observationAtIndexPath:indexPath];
		[destination setObservation:observation];
    }
}

-(void) refreshObservations {
    NSLog(@"refreshObservations");
}

@end
