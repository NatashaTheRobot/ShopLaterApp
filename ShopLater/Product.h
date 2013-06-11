//
//  Product.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image, Provider;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *prices;
@property (nonatomic, retain) Provider *provider;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addPricesObject:(NSManagedObject *)value;
- (void)removePricesObject:(NSManagedObject *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;

@end
