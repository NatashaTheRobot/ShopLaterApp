//
//  ProductTableViewCell.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProductTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ProductTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;


@end

@implementation ProductTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setProductName:(NSString *)productName
{
    _productName = productName;
    self.productNameLabel.text = productName;
}

- (void)setProductImage:(UIImage *)productImage
{
    _productImage = productImage;
    self.productImageView.layer.borderColor = [[UIColor colorWithRed:128/255.0 green:128/255.0  blue:128/255.0 alpha:1] CGColor];
    self.productImageView.layer.borderWidth = 1.0;
    self.productImageView.image = productImage;
}

- (void)setCurrentPrice:(NSString *)currentPrice
{
    _currentPrice = currentPrice;
    self.currentPriceLabel.text = currentPrice;
}

- (void)setWishPrice:(NSString *)wishPrice
{
    _wishPrice = wishPrice;
    self.wishPriceLabel.text = wishPrice;
}

@end
