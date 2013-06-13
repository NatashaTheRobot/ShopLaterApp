//
//  ToysrusParser.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/9/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParserDelegate.h"

@interface ToysrusParser : NSObject <ParserDelegate>

@property (strong, nonatomic) NSString *cleanURLString;
@property (strong, nonatomic) NSString *mobileURLString;

- (NSString *)productName;
- (NSString *)productSummary;
- (NSNumber *)priceInDollars;
- (Price *)productPrice;
- (Image *)productImage;

@end
