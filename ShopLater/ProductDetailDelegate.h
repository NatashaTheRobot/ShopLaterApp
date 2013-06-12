//
//  ProductDetailDelegate.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/12/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProductDetailDelegate <NSObject>

- (void)reloadProductDetailData;
- (void)deleteProduct;

@end
