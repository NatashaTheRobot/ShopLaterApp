//
//  ProductCollectionViewCell.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/17/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProductCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Image+SLExtensions.h"
#import "Constants.h"
#import "Provider.h"
#import "Parser.h"
#import "Price+SLExtensions.h"
#import "CoreDataManager.h"

@interface ProductCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)deleteProductWithButton:(id)sender;

@end

@implementation ProductCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            self.currentPriceLabel.text = [self.product formattedPriceWithType:sPriceTypeCurrent];
        });
    });
}

- (IBAction)deleteProductWithButton:(id)sender
{
    [self.delegate deleteProduct:self.product];
}

@end
