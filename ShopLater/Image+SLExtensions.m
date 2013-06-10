//
//  Image+SLExtensions.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/9/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Image+SLExtensions.h"

@implementation Image (SLExtensions)

+ (UIImage *)imageForProvider:(Provider *)provider type:(NSString *)imageType
{
    NSString *filter = [NSString stringWithFormat:@"fileName = '%@_%@.png'", provider.name, imageType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:filter];
    Image *image = [[provider.images filteredSetUsingPredicate:predicate] anyObject];
    
    return [UIImage imageNamed:image.fileName];
}

+ (NSString *)downloadImageFromURL:(NSURL *)imageURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectoryURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSString *imageFileName = [imageURL lastPathComponent];
    NSURL *localImageURL = [documentDirectoryURL URLByAppendingPathComponent:imageFileName];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imageURL]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   [data writeToURL:localImageURL atomically:YES];
                               } else {
                                   NSLog(@"Image NOT downloaded with URL: %@", imageURL.absoluteString);
                               }
                           }];
    
    return imageFileName;
    
}

- (UIImage *)image
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectoryURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *localImageURL = [documentDirectoryURL URLByAppendingPathComponent:self.fileName];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[localImageURL path]];
    return image;
}


@end
