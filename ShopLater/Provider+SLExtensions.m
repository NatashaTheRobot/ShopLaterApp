//
//  Provider+SLExtensions.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/10/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Provider+SLExtensions.h"
#import "CoreDataManager.h"
#import "Image+SLExtensions.h"
#import "Constants.h"
#import "Identifier+SLExtensions.h"

@implementation Provider (SLExtensions)

+ (NSString *)urlStringFromProviderName:(NSString *)providerName
{
    return [NSString stringWithFormat:@"http://www.%@.com", providerName];
}

+ (NSString *)logoImageNameFromProviderName:(NSString *)providerName
{
    return [NSString stringWithFormat:@"%@_%@.png", providerName, sImageTypeLogo];
}

+ (NSString *)exampleImageNameFromProviderName:(NSString *)providerName
{
    return [NSString stringWithFormat:@"%@_%@.png", providerName, sImageTypeExample];
}

+ (NSString *)sectionImageNameFromProviderName:(NSString *)providerName
{
    return [NSString stringWithFormat:@"%@_%@.png", providerName, sImageTypeSection];
}

+ (NSArray *)providersArray
{
    NSMutableArray *providers = [[NSMutableArray alloc] initWithCapacity:3];
    
    [providers addObject:[self dictionaryWithProviderName:@"toysrus"
                                              identifiers:[Identifier identifiersWithNames:@[@"productId"]]]];
    
    [providers addObject:[self dictionaryWithProviderName:@"homedepot"
                                              identifiers:[Identifier identifiersWithNames:@[@"/p/"]]]];
    
    [providers addObject:[self dictionaryWithProviderName:@"bestbuy" identifiers:[Identifier identifiersWithNames:@[@"/product/"]]]];

    return providers;
}

#pragma mark - provider dictionary

+ (NSDictionary *)dictionaryWithProviderName:(NSString *)providerName identifiers:(NSSet *)identifiers
{
    CoreDataManager *coreDataManager = [CoreDataManager sharedManager];
    
    NSDictionary *logoImageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [Provider logoImageNameFromProviderName:providerName], @"fileName",
                                                nil];
    Image *logoImage = [coreDataManager createEntityWithClassName:NSStringFromClass([Image class])
                                                          attributesDictionary:logoImageDictionary];
    
    NSDictionary *exampleImageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [Provider exampleImageNameFromProviderName:providerName], @"fileName",
                                                   nil];
    
    Image *exampleImage =  [coreDataManager createEntityWithClassName:NSStringFromClass([Image class])
                                                              attributesDictionary:exampleImageDictionary];
    
    NSDictionary *providerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:providerName, @"name",
                                       identifiers, @"identifiers",
                                       [Provider urlStringFromProviderName:providerName], @"url",
                                       [NSSet setWithObjects:logoImage, exampleImage, nil], @"images",
                                       nil];
    return providerDictionary;
}

@end
