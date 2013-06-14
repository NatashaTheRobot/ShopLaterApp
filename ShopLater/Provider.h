//
//  Provider.h
//  ShopLater
//
//  Created by Reza Fatahi on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Identifier, Image, Product;

@interface Provider : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *products;
@property (nonatomic, retain) NSSet *identifiers;
@end

@interface Provider (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addProductsObject:(Product *)value;
- (void)removeProductsObject:(Product *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

- (void)addIdentifiersObject:(Identifier *)value;
- (void)removeIdentifiersObject:(Identifier *)value;
- (void)addIdentifiers:(NSSet *)values;
- (void)removeIdentifiers:(NSSet *)values;

@end
