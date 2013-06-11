//
//  ProductTableViewCell.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImage *productImage;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *currentPrice;
@property (strong, nonatomic) NSString *wishPrice;

@end
