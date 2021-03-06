//
//  TopshopParser.h
//  ShopLater
//
//  Created by Reza Fatahi on 6/20/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParserDelegate.h"

@interface TopshopParser : NSObject <ParserDelegate>

@property (strong, nonatomic) NSString *cleanURLString;
@property (strong, nonatomic) NSString *mobileURLString;

- (NSString *)productName;
- (NSNumber *)priceInDollars;
- (Price *)productPrice;
- (Image *)productImage;

@end
