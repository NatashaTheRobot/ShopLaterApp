//
//  Product.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Product : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *prices;
@property (nonatomic, retain) NSSet *providers;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addImagesObject:(NSManagedObject *)value;
- (void)removeImagesObject:(NSManagedObject *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addPricesObject:(NSManagedObject *)value;
- (void)removePricesObject:(NSManagedObject *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;

- (void)addProvidersObject:(NSManagedObject *)value;
- (void)removeProvidersObject:(NSManagedObject *)value;
- (void)addProviders:(NSSet *)values;
- (void)removeProviders:(NSSet *)values;

@end
