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

@end
