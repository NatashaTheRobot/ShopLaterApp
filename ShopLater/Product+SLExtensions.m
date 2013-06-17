//
//  Product+SLExtensions.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Product+SLExtensions.h"
#import "Image+SLExtensions.h"
#import "Price+SLExtensions.h"
#import "Constants.h"
#import "CoreDataManager.h"

@implementation Product (SLExtensions)

- (UIImage *)image
{
    return [(Image *)[self.images anyObject] image];
}

- (Price *)priceWithType:(NSString *)type
{
    NSPredicate *priceFilter = [NSPredicate predicateWithFormat:@"type == %@", type];
    return [[self.prices filteredSetUsingPredicate:priceFilter] anyObject];
}

- (NSString *)formattedPriceWithType:(NSString *)type
{
    Price *price = [self priceWithType:type];
    return [Price formattedPriceFromNumber:price.dollarAmount];
}

- (NSNumber *)currentWishPriceDifference
{
    CGFloat currentPrice = [[self priceWithType:sPriceTypeCurrent].dollarAmount floatValue];
    CGFloat wishPrice = [[self priceWithType:sPriceTypeWish].dollarAmount floatValue];
    CGFloat priceDifference = currentPrice - wishPrice;
    
    return [NSNumber numberWithFloat:priceDifference];
}

@end
