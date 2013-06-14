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
    NSMutableArray *providers = [[NSMutableArray alloc] initWithCapacity:2];
    
    [providers addObject:[self dictionaryWithProviderName:@"toysrus" identifierName:@"productId"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"macys" identifierName:@"productId"]];
    
    return providers;
}

#pragma mark - provider dictionary

+ (NSDictionary *)dictionaryWithProviderName:(NSString *)providerName identifierName:(NSString *)identifierName
{
    CoreDataManager *coreDataManager = [CoreDataManager sharedManager];
    
    NSDictionary *logoImageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [Provider logoImageNameFromProviderName:providerName], @"fileName",
                                                nil];
    Image *logoImage = [coreDataManager createEntityWithClassName:NSStringFromClass([Image class])
                                                          atributesDictionary:logoImageDictionary];
    
    NSDictionary *exampleImageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [Provider exampleImageNameFromProviderName:providerName], @"fileName",
                                                   nil];
    
    Image *exampleImage =  [coreDataManager createEntityWithClassName:NSStringFromClass([Image class])
                                                              atributesDictionary:exampleImageDictionary];
    
    NSDictionary *providerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:providerName, @"name",
                                       identifierName, @"identifierName",
                                       [Provider urlStringFromProviderName:providerName], @"url",
                                       [NSSet setWithObjects:logoImage, exampleImage, nil], @"images",
                                       nil];
    return providerDictionary;
}

@end
