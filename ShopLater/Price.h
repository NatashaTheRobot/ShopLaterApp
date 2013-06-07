//
//  Price.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Price : NSManagedObject

@property (nonatomic, retain) NSNumber * dollarAmount;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Product *product;

@end
