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
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *priceMatchImageView;
@property (weak, nonatomic) IBOutlet UIView *buyView;
@property (weak, nonatomic) IBOutlet UIButton *buyNowButton;
@property (weak, nonatomic) IBOutlet UIView *labelView;

@property (strong, nonatomic) UILabel *productNameLabel;

- (void)setupView;

- (IBAction)deleteProductWithButton:(id)sender;
- (IBAction)buyNowWithButton:(id)sender;

@end

@implementation ProductCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    self.layer.masksToBounds = NO;
    
    self.contentView.layer.cornerRadius = 4;
    self.contentView.layer.borderColor = [[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.3] CGColor];
    self.contentView.layer.borderWidth = 1;
    
    self.layer.cornerRadius = 4;
    self.layer.shadowColor = [[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1] CGColor];
    self.layer.shadowOffset = CGSizeMake(2, 2);
    self.layer.shadowRadius = 1;
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        cornerRadius:4] CGPath];
    self.layer.shadowOpacity = 0.5;
    
    self.buyNowButton.layer.cornerRadius = 4;
    self.buyNowButton.layer.masksToBounds = YES;
    
    self.buyView.layer.cornerRadius = 4;
    self.buyView.layer.masksToBounds = YES;
    
    self.backgroundView.layer.cornerRadius = 4;
}

- (void)setProduct:(Product *)product
{
    _product = product;
    
    NSString *text = product.name;
    CGSize maximumLabelSize = CGSizeMake(250, CGFLOAT_MAX);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    CGSize expectedLabelSize = [text sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    self.productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 250, expectedLabelSize.height)];
    self.productNameLabel.text = [product formattedName:product.name];
    self.productNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.productNameLabel.numberOfLines = 0;
    self.productNameLabel.font = font;
    
    [self.labelView addSubview:self.productNameLabel];
    
    self.productImageView.image = [product image];
    self.currentPriceLabel.text = [product formattedPriceWithType:sPriceTypeCurrent];
    self.wishPriceLabel.text = [product formattedPriceWithType:sPriceTypeWish];
    self.logoImageView.image = [Image imageForProvider:product.provider type:sImageTypeLogo];
    
    if ([product.priceDifference floatValue] <= 0) {
        self.priceMatchImageView.alpha = 1;
    }
    
    [self.activityIndicator startAnimating];
    
    if ([product.priceLoadedInSession integerValue] == 0) {
        [self parseCurrentPrice];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

- (void)parseCurrentPrice
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        Parser *parser = [Parser parserWithProviderName:self.product.provider.name productURLString:self.product.mobileURL];
        NSNumber *newPrice;
        
        if (parser) {
            @try {
                newPrice = [parser.delegate priceInDollars];
            }
            @catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                });
                return;
            }
            @finally {
                if (newPrice) {
                    Price *currentPrice = [self.product priceWithType:sPriceTypeCurrent];
                    self.product.priceLoadedInSession = [NSNumber numberWithInteger:1];
                    if ([currentPrice.dollarAmount floatValue] != [newPrice floatValue]) {
                        currentPrice.dollarAmount = newPrice;
                        self.product.priceDifference = [self.product priceDifference];
                        [[CoreDataManager sharedManager] saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
                            if (saved) {
                            }
                        }];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
                        self.currentPriceLabel.text = [self.product formattedPriceWithType:sPriceTypeCurrent];
                        if ([self.product.priceDifference floatValue] <= 0) {
                            self.priceMatchImageView.alpha = 1;
                        }
                    });

                }
            }
            
            
        }
    });
}

- (IBAction)deleteProductWithButton:(id)sender
{
    [self.delegate deleteProduct:self.product];
}

- (IBAction)buyNowWithButton:(id)sender
{
    [self.delegate buyProduct:self.product];
}

- (void)removeProductLabel
{
    [self.productNameLabel removeFromSuperview];
}

@end
