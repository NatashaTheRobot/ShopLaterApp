//
//  Product+SLExtensions.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Product.h"
@class Price;

@interface Product (SLExtensions)

- (UIImage *)image;

- (NSString *)priceWithType:(NSString *)type;

@end
