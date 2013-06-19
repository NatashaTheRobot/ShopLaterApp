//
//  ProductDelegate.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/17/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Product;

@protocol ProductDelegate <NSObject>

- (void)deleteProduct:(Product *)product;
- (void)buyProduct:(Product *)product;

@end
