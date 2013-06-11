//
//  Price+SLExtensions.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Price.h"

@interface Price (SLExtensions)

+ (NSString *)formattedPriceFromNumber:(NSNumber *)dollarAmount;

@end
