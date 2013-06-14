//
//  Provider+SLExtensions.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/10/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Provider.h"

@interface Provider (SLExtensions)

+ (NSString *)urlStringFromProviderName:(NSString *)providerName;
+ (NSString *)logoImageNameFromProviderName:(NSString *)providerName;
+ (NSString *)exampleImageNameFromProviderName:(NSString *)providerName;
+ (NSString *)sectionImageNameFromProviderName:(NSString *)providerName;

+ (NSArray *)providersArray;
+ (NSDictionary *)dictionaryWithProviderName:(NSString *)providerName identifiers:(NSSet *)identifiers
;

@end
