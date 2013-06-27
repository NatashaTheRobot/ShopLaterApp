//
//  AnthropologieParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/26/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "AnthropologieParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface AnthropologieParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation AnthropologieParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    AnthropologieParser *parser = [[AnthropologieParser alloc] init];
    parser.mobileURLString = productURLString;
    parser.cleanURLString = productURLString;
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:productURLString]];
    parser.htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (parser.htmlString == nil) {
        parser.htmlString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    parser.coreDataManager = [CoreDataManager sharedManager];
    
    return parser;
}

# pragma mark - Property Delegate Methods

- (NSNumber *)priceInDollars
{
    NSString *priceString;
    if ([self.htmlString containsString:@"\"price-sale\""]) {
        priceString = [Parser scanString:self.htmlString startTag:@"<span class=\"price-sale\">" endTag:@"span"];
        if ([priceString containsString:@"-"]) {
            priceString = [Parser scanString:priceString startTag:@"$" endTag:@"-"];
        } else {
            priceString = [Parser scanString:priceString startTag:@"$" endTag:@"</"];
        }
    } else {
        priceString = [Parser scanString:self.htmlString startTag:@" <span id=\"productdetail-price\">" endTag:@"span"];
        if ([priceString containsString:@"-"]) {
            priceString = [Parser scanString:priceString startTag:@"$" endTag:@"-"];
        } else {
            priceString = [Parser scanString:priceString startTag:@"$" endTag:@"</"];
        }
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
        
        NSString *name = [Parser scanString:self.htmlString startTag:@"<title>" endTag:@"title>"];
        self.name = [Parser scanString:name startTag:@" - " endTag:@"</"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *image = [Parser scanString:self.htmlString startTag:@"<div id=\"productdetail-images\">" endTag:@"</li"];
        NSString *urlString= [Parser scanString:image startTag:@"img src=\"" endTag:@"\""];
        NSURL *urlImage = [NSURL URLWithString:urlString];
        NSString *imageFileName = [Image imageFileNameForURL:urlImage];
        NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName",
                                         urlString, @"externalURLString",
                                         nil];
        self.image = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Image class]) attributesDictionary:imageDictionary];
        
    }
    return self.image;
}

@end


