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

+ (NSArray *)providersArray
{
    NSMutableArray *providers = [[NSMutableArray alloc] initWithCapacity:4];
    
    [providers addObject:[self dictionaryWithProviderName:@"toysrus"
                                              identifiers:[Identifier identifiersWithNames:@[@"productId"]]
                                           commercialName:@"Toysrus"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"homedepot"
                                              identifiers:[Identifier identifiersWithNames:@[@"/p/"]]
                                           commercialName:@"HomeDepot"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"macys"
                                              identifiers:[Identifier identifiersWithNames:@[@"/product/"]]
                                           commercialName:@"Macy's"]];

    [providers addObject:[self dictionaryWithProviderName:@"bestbuy"
                                              identifiers:[Identifier identifiersWithNames:@[@"/product/"]]
                                           commercialName:@"BestBuy"]];

    return providers;
}

#pragma mark - provider dictionary

+ (NSDictionary *)dictionaryWithProviderName:(NSString *)providerName
                                 identifiers:(NSSet *)identifiers
                              commercialName:(NSString *)commercialName
{
    CoreDataManager *coreDataManager = [CoreDataManager sharedManager];
    
    NSDictionary *logoImageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [Provider logoImageNameFromProviderName:providerName], @"fileName",
                                                nil];
    
    Image *logoImage = [coreDataManager createEntityWithClassName:NSStringFromClass([Image class])
                                             attributesDictionary:logoImageDictionary];
    
    NSDictionary *providerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:providerName, @"name",
                                       identifiers, @"identifiers",
                                       [Provider urlStringFromProviderName:providerName], @"url",
                                       [NSSet setWithObjects:logoImage, nil], @"images",
                                        commercialName, @"commercialName",
                                       nil];
    return providerDictionary;
}

@end
