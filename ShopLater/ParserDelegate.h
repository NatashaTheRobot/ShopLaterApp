//
//  ParserDelegate.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/10/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Price;
@class Image;

@protocol ParserDelegate <NSObject>

+ (id)parserWithProductURLString:(NSString *)productURLString;

- (NSString *)productName;
- (NSString *)productSummary;
- (Price *)productPrice;
- (Image *)productImage;

@end
