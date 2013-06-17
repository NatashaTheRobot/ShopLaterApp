//
//  ProductTableViewCell.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDelegate.h"
#import "Product+SLExtensions.h"

@interface ProductTableViewCell : UITableViewCell

@property (strong, nonatomic) Product *product;

@property (strong, nonatomic) id<ProductDelegate> delegate;

@end
