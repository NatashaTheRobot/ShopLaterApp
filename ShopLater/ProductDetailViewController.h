//
//  ProductDetailViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product+SLExtensions.h"
#import "ProductDelegate.h"

@interface ProductDetailViewController : UIViewController

@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) id<ProductListDelegate> delegate;

@end
