//
//  Price+SLExtensions.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Price+SLExtensions.h"

@implementation Price (SLExtensions)

+ (NSString *)formattedPriceFromNumber:(NSNumber *)dollarAmount
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.currencyCode = @"USD";
    
    return [numberFormatter stringFromNumber:dollarAmount];
}

@end
