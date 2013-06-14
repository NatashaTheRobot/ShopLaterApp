//
//  Product.h
//  ShopLater
//
//  Created by Reza Fatahi on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image, Price, Provider;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * mobileURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priceDifference;
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

- (void)addPricesObject:(Price *)value;
- (void)removePricesObject:(Price *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;

@end
