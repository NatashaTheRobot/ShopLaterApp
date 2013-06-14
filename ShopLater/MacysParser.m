//
//  MacysParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "MacysParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface MacysParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

- (NSString *)getProductIdFromURLString:(NSString *)urlString;
- (NSString *)getProductNameFromURLString:(NSString *)urlString;

@end

@implementation MacysParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    MacysParser *parser = [[MacysParser alloc] init];
    parser.mobileURLString = productURLString;
    
    NSString *productId = [parser getProductIdFromURLString:productURLString];
    
    NSString *nameId = [parser getProductNameFromURLString:productURLString];
    
    // handle error (if we cannot get the product id for some reason)
    parser.cleanURLString = [NSString stringWithFormat:@"http://www1.macys.com/shop/product/%@?ID=%@", nameId, productId];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:parser.cleanURLString]];
    
    parser.htmlString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
    parser.coreDataManager = [CoreDataManager sharedManager];
    
    return parser;
}

- (NSString *)getProductIdFromURLString:(NSString *)urlString
{
    return [Parser scanString:urlString startTag:@"?ID=" endTag:@"&"];
}

- (NSString *)getProductNameFromURLString:(NSString *)urlString
{
    return [Parser scanString:urlString startTag:@"product/" endTag:@"?"];
}

# pragma mark - Property Delegate Methods

- (NSNumber *)priceInDollars
{
    NSString *priceString;
    
    if ([self.htmlString containsString:@"<!-- PRICE BLOCK: Single Price -->"]) {
        
        priceString = [Parser scanString:self.htmlString startTag:@"<!-- PRICE BLOCK: Single Price -->" endTag:@"<br>"];
        priceString = [Parser scanString:priceString startTag:@"$" endTag:@"</"];
        priceString = [priceString stringByReplacingOccurrencesOfString:@"," withString:@""];

    } else {
        
        priceString = [Parser scanString:self.htmlString startTag:@"<span>Was" endTag:@"<br>"];
        priceString = [Parser scanString:priceString startTag:@"$" endTag:@"</"];
        priceString = [priceString stringByReplacingOccurrencesOfString:@"," withString:@""];

    }
    
    return [NSNumber numberWithFloat:[priceString floatValue]];
}

- (Price *)productPrice
{
    if (!self.price) {
        
        NSDictionary *priceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [self priceInDollars], @"dollarAmount",
                                         sPriceTypeCurrent, @"type",
                                         [NSDate date], @"created_at", nil];
        self.price = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Price class])
                                                 attributesDictionary:priceDictionary];
    }
    
    return self.price;
}


- (NSString *)productName
{
    if (!self.name) {
        
        self.name = [Parser scanString:self.htmlString startTag:@"itemprop=\"name\">" endTag:@"</h1>"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *imageString = [Parser scanString:self.htmlString startTag:@"property=\"og:image\" content=\"" endTag:@"\" />"];
        
        NSURL *urlImage = [NSURL URLWithString:imageString];
        
        NSString *imageFileName = [Image imageFileNameForURL:urlImage];
        
        NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName",
                                         imageString, @"externalURLString",
                                         nil];
        self.image = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Image class]) attributesDictionary:imageDictionary];
        
    }
    return self.image;
}

@end
