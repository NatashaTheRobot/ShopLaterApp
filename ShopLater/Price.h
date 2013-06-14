//
//  Price.h
//  ShopLater
//
//  Created by Reza Fatahi on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Price : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * dollarAmount;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Product *product;

@end
