//
//  Provider.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/15/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identifier, Image, Product;

@interface Provider : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * commercialName;
@property (nonatomic, retain) NSSet *identifiers;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *products;
@end

@interface Provider (CoreDataGeneratedAccessors)

- (void)addIdentifiersObject:(Identifier *)value;
- (void)removeIdentifiersObject:(Identifier *)value;
- (void)addIdentifiers:(NSSet *)values;
- (void)removeIdentifiers:(NSSet *)values;

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addProductsObject:(Product *)value;
- (void)removeProductsObject:(Product *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
