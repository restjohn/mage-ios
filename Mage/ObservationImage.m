//
//  ObservationImage.m
//  Mage
//
//  Created by Dan Barela on 7/17/14.
//  Copyright (c) 2014 Dan Barela. All rights reserved.
//

#import "ObservationImage.h"

@implementation ObservationImage

+ (NSString *) imageNameForObservation:(Observation *) observation {
	if (!observation) return nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *formId = [defaults objectForKey: @"formId"];
    NSString *rootIconFolder = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat: @"/form-%@/form/icons", formId]];
    
    NSString *type = [observation.properties objectForKey:@"type"];
    
    NSDictionary *form = [defaults objectForKey:@"form"];
    NSString *variantField = [form objectForKey:@"variantField"];
    NSMutableArray *iconProperties = [[NSMutableArray alloc] initWithArray: @[type]];
    if (variantField != nil) {
        [iconProperties addObject: [observation.properties objectForKey:variantField]];
    }
    
    BOOL foundIcon = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    while(!foundIcon) {
        NSString *iconPath = [iconProperties componentsJoinedByString:@"/"];
        NSString *directoryToSearch = [rootIconFolder stringByAppendingPathComponent:iconPath];
        if ([fileManager fileExistsAtPath:directoryToSearch]) {
            NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:[rootIconFolder stringByAppendingPathComponent:iconPath] error:nil];
            if ([directoryContents count] != 0) {
                for (NSString *path in directoryContents) {
                    NSString *filename = [path lastPathComponent];
                    if ([filename hasPrefix:@"icon"]) {
                        return [[rootIconFolder stringByAppendingPathComponent:iconPath] stringByAppendingPathComponent:path];
                    }
                }
            }
        } else {
            if ([iconProperties count] == 0) {
                foundIcon = YES;
            }
            [iconProperties removeLastObject];
        }
    }
    return nil;
}

+ (UIImage *) imageForObservation:(Observation *) observation scaledToWidth: (NSNumber *) width {
    NSString *imagePath = [ObservationImage imageNameForObservation:observation];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    [image setAccessibilityIdentifier:imagePath];
    
    if (width != nil && image != nil) {
        float oldWidth = image.size.width;
        float scaleFactor = [width floatValue] / oldWidth;
        
        float newHeight = image.size.height * scaleFactor;
        float newWidth = oldWidth * scaleFactor;
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [image drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [newImage setAccessibilityIdentifier:[image accessibilityIdentifier]];
        return newImage;
    }
	return image;
}

@end