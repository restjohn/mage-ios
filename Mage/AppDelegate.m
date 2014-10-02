//
//  AppDelegate.m
//  Mage
//
//  Created by Dan Barela on 2/13/14.
//  Copyright (c) 2014 Dan Barela. All rights reserved.
//

#import "AppDelegate.h"
#import <User.h>
#import <GeoPoint.h>
#import <CoreLocation/CoreLocation.h>
#import <FICImageCache.h>
#import <UserUtility.h>
#import "Attachment+FICAttachment.h"

#import "MageInitialViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize locationFetchService = _locationFetchService;
@synthesize observationFetchService = _observationFetchService;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSURL *sdkPreferencesFile = [[NSBundle mainBundle] URLForResource:@"MageSDK.bundle/preferences" withExtension:@"plist"];
    NSDictionary *sdkPreferences = [NSDictionary dictionaryWithContentsOfURL:sdkPreferencesFile];
    
    NSURL *defaultPreferencesFile = [[NSBundle mainBundle] URLForResource:@"preferences" withExtension:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfURL:defaultPreferencesFile];
    
    NSMutableDictionary *allPreferences = [[NSMutableDictionary alloc] initWithDictionary:sdkPreferences];
    [allPreferences addEntriesFromDictionary:defaultPreferences];
    [[NSUserDefaults standardUserDefaults]  registerDefaults:allPreferences];
    
    FICImageFormat *thumbnailImageFormat = [[FICImageFormat alloc] init];
    thumbnailImageFormat.name = AttachmentSmallSquare;
    thumbnailImageFormat.family = AttachmentFamily;
    thumbnailImageFormat.style = FICImageFormatStyle16BitBGR;
    thumbnailImageFormat.imageSize = AttachmentSquareImageSize;
    thumbnailImageFormat.maximumCount = 250;
    thumbnailImageFormat.devices = FICImageFormatDevicePhone;
    thumbnailImageFormat.protectionMode = FICImageFormatProtectionModeNone;
    
    FICImageFormat *largeImageFormat = [[FICImageFormat alloc] init];
    largeImageFormat.name = AttachmentLarge;
    largeImageFormat.family = AttachmentFamily;
    largeImageFormat.style = FICImageFormatStyle32BitBGRA;
    largeImageFormat.imageSize = [[UIScreen mainScreen] bounds].size;
    largeImageFormat.maximumCount = 250;
    largeImageFormat.devices = FICImageFormatDevicePhone;
    largeImageFormat.protectionMode = FICImageFormatProtectionModeNone;
    
    NSArray *imageFormats = @[thumbnailImageFormat, largeImageFormat];
    
    _imageCache = [FICImageCache sharedImageCache];
    _imageCache.delegate = self;
    _imageCache.formats = imageFormats;
    
    _locationFetchService = [[LocationFetchService alloc] initWithManagedObjectContext:[self managedObjectContext]];
    
    _observationFetchService = [[ObservationFetchService alloc] initWithManagedObjectContext:[self managedObjectContext]];
	 
	return YES;
}

- (void) applicationWillResignActive:(UIApplication *) application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
}

- (void) applicationDidEnterBackground:(UIApplication *) application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    
    [_locationFetchService stop];
}

- (void) applicationWillEnterForeground:(UIApplication *) application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
    if (![UserUtility isTokenExpired]) {
        [_locationFetchService start];
    }
}

- (void) applicationDidBecomeActive:(UIApplication *) application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");

}

- (void) applicationWillTerminate:(UIApplication *) application {
    NSLog(@"applicationWillTerminate");

    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle]
     URLForResource:@"MageSDK.bundle" withExtension:@"momd"];
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
     //[[NSBundle mainBundle] URLForResource:@"Mage" withExtension:@"momd"];
    //_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Mage.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Fetch the desired source image by making a network request
        Attachment *attachment = (Attachment *)entity;
        UIImage *sourceImage = nil;
        NSURL *requestURL = [entity sourceImageURLWithFormatName:formatName];
        if ([attachment.contentType hasPrefix:@"image"]) {
            
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            NSString *tokenUrl = [NSString stringWithFormat:@"%@?access_token=%@", requestURL, [defaults objectForKey:@"token"]];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:tokenUrl]];
            sourceImage = [UIImage imageWithData:data];
        } else if ([attachment.contentType hasPrefix:@"video"]) {
            sourceImage = [UIImage imageNamed:@"video"];
        } else {
            sourceImage = [UIImage imageNamed:@"download"];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sourceImage);
        });
    });
}

@end
