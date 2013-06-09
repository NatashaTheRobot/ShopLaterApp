//
//  CoreDataManager.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;
@class Price;
@class Provider;
@class Product;

@interface CoreDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (CoreDataManager *)sharedManager;

- (BOOL)saveDataInManagedContext;

#pragma mark - Products
- (BOOL)productsExist;
- (Product *)createProductWithDictionary:(NSDictionary *)productDictionary;

#pragma mark - Providers
- (BOOL)providersExist;
- (Provider *)createProviderWithDictionary:(NSDictionary *)providerDictionary;

#pragma mark - Images
- (Image *)createImageWithDictionary:(NSDictionary *)imageDictionary;

#pragma mark - Prices
- (Price *)createPriceWithDictionary:(NSDictionary *)priceDictionary;

@end
