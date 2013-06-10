//
//  ToysrusParser.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/9/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Price;
@class Image;

@interface ToysrusParser : NSObject

+ (ToysrusParser *)parserWithProductID:(NSString *)productURLString;

- (NSString *)productName;
- (NSString *)productSummary;
- (Price *)productPrice;
- (Image *)productImage;


@end
