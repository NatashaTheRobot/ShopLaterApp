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
    if ([providerName isEqualToString:@"nordstrom"]) {
        return [NSString stringWithFormat:@"http://shop.%@.com", providerName];
    } else if ([providerName isEqualToString:@"underarmour"]) {
        return @"http://m.underarmour.com/shop/us/en";
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
    NSMutableArray *providers = [[NSMutableArray alloc] initWithCapacity:17];
    
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
                                              identifiers:[Identifier identifiersWithNames:@[@"/product/"]]
                                           commercialName:@"Bed Bath & Beyond"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"lululemon"
                                              identifiers:[Identifier identifiersWithNames:@[@"/products/"]]
                                           commercialName:@"Lululemon"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"buybuybaby"
                                              identifiers:[Identifier identifiersWithNames:@[@"/product/"]]
                                           commercialName:@"Buy Buy Baby"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"nordstrom"
                                              identifiers:[Identifier identifiersWithNames:@[@"/Product/Details/"]]
                                           commercialName:@"Nordstrom"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"jcrew"
                                              identifiers:[Identifier identifiersWithNames:@[@"/PRDOVR"]]
                                           commercialName:@"J.Crew"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"underarmour"
                                              identifiers:[Identifier identifiersWithNames:@[@"/pid"]]
                                           commercialName:@"Under Armour"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"westelm"
                                              identifiers:[Identifier identifiersWithNames:@[@"pkey="]]
                                           commercialName:@"West Elm"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"topshop"
                                              identifiers:[Identifier identifiersWithNames:@[@"/ProductDisplay?"]]
                                           commercialName:@"TOPSHOP"]];

    [providers addObject:[self dictionaryWithProviderName:@"anthropologie"
                                              identifiers:[Identifier identifiersWithNames:@[@"/productdetail."]]
                                           commercialName:@"Anthropologie"]];
    
    [providers addObject:[self dictionaryWithProviderName:@"net-a-porter"
                                              identifiers:[Identifier identifiersWithNames:@[@"/product/"]]
                                           commercialName:@"Net-A-Porter"]];
    
    
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
