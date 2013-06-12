//
//  ProductDetailDelegate.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/12/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Product;

@protocol ProductDetailDelegate <NSObject>

- (void)reloadProductDetails;
- (void)deleteProduct;

@end
