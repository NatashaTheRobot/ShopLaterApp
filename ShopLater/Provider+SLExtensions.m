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
    if ([providerName isEqualToString:@"dupontregistry"]) {
        return [NSString stringWithFormat:@"http://m.%@.com", providerName];
    } else if ([providerName isEqualToString:@"nordstrom"]) {
        return [NSString stringWithFormat:@"http://shop.%@.com", providerName];
    } else if ([providerName isEqualToString:@"ikea"]) {
        return [NSString stringWithFormat:@"http://m.%@.com/us/en", providerName];
    } else {
        return [NSString stringWithFormat:@"http://www.%@.com", providerName];
    }
}


+ (NSString *)logoImageNameFromProviderName:(NSString *)providerName
{
    return [NSString stringWithFormat:@"%@_%@.png", providerName, sImageTypeLogo];
}

+ (NSArray *)providersArray
{
    NSMutableArray *providers = [[NSMutableArray alloc] initWithCapacity:11];
    
    [providers addObject:[self dictionaryWithProviderName:@"toysrus"
                                              identifiers:[Identifier identifiersWithNames:@[@"productId"]]
                                           commercialName:@"Toys\"R\"Us"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"homedepot"
                                              identifiers:[Identifier identifiersWithNames:@[@"/p/"]]
                                           commercialName:@"HomeDepot"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"macys"
                                              identifiers:[Identifier identifiersWithNames:@[@"/product/"]]
                                           commercialName:@"Macy's"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"bestbuy"
                                              identifiers:[Identifier identifiersWithNames:@[@"/product/"]]
                                           commercialName:@"BestBuy"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"bedbathbeyond"
                                              identifiers:[Identifier identifiersWithNames:@[@"/product/detail."]]
                                           commercialName:@"Bed Bath & Beyond"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"lululemon"
                                              identifiers:[Identifier identifiersWithNames:@[@"skuId"]]
                                           commercialName:@"Lululemon"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"dupontregistry"
                                              identifiers:[Identifier identifiersWithNames:@[@"ItemID"]]
                                           commercialName:@"Dupont Registry"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"buybuybaby"
                                              identifiers:[Identifier identifiersWithNames:@[@"/product/detail."]]
                                           commercialName:@"Buy Buy Baby"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"nordstrom"
                                              identifiers:[Identifier identifiersWithNames:@[@"/Product/Details/"]]
                                           commercialName:@"Nordstrom"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"sears"
                                              identifiers:[Identifier identifiersWithNames:@[@"/productdetails.do?partNumber="]]
                                           commercialName:@"Sears"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"ikea"
                                              identifiers:[Identifier identifiersWithNames:@[@"catalog/products/"]]
                                           commercialName:@"Ikea"]];
    
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
