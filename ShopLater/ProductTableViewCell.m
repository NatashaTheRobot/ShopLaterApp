//
//  ProductTableViewCell.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProductTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Image+SLExtensions.h"
#import "Constants.h"
#import "Provider.h"
#import "Parser.h"
#import "Price+SLExtensions.h"
#import "CoreDataManager.h"

@interface ProductTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)deleteProductWithButton:(id)sender;

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

- (void)setProduct:(Product *)product
{
    _product = product;
    self.productNameLabel.text = [product formattedName:product.name];
    self.productImageView.image = [product image];
    self.currentPriceLabel.text = [product formattedPriceWithType:sPriceTypeCurrent];
    self.wishPriceLabel.text = [product formattedPriceWithType:sPriceTypeWish];
    self.logoImageView.image = [Image imageForProvider:product.provider type:sImageTypeLogo];
    
    [self.activityIndicator startAnimating];
    [self parseCurrentPrice];
}

- (void)parseCurrentPrice
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Parser *parser = [Parser parserWithProviderName:self.product.provider.name productURLString:self.product.mobileURL];
        Price *currentPrice = [self.product priceWithType:sPriceTypeCurrent];
        NSNumber *newPrice = [parser.delegate priceInDollars];
        if ([currentPrice.dollarAmount floatValue] != [newPrice floatValue]) {
            currentPrice.dollarAmount = newPrice;
            [[CoreDataManager sharedManager] saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
                if (saved) {
                }
            }];
        }
        [self.activityIndicator stopAnimating];
        self.currentPriceLabel.text = [self.product formattedPriceWithType:sPriceTypeCurrent];

    });
}

- (IBAction)deleteProductWithButton:(id)sender
{
    [self.delegate deleteProduct:self.product];
}
@end
