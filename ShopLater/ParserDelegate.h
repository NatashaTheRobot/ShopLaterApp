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

+ (instancetype)parserWithProductURLString:(NSString *)productURLString;

@property (strong, nonatomic) NSString *mobileURLString;

- (NSString *)productName;
- (NSString *)productSummary;
- (Price *)productPrice;
- (Image *)productImage;

@end
