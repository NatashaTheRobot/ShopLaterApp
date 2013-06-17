//
//  BuybuybabyParse.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/17/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "BuybuybabyParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface BuybuybabyParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation BuybuybabyParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{    
    BuybuybabyParser *parser = [[BuybuybabyParser alloc] init];
    parser.cleanURLString = productURLString;
    parser.mobileURLString = productURLString;
    
    // handle error (if we cannot get the product id for some reason)
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:parser.cleanURLString]];
    
    parser.htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    parser.coreDataManager = [CoreDataManager sharedManager];
    
    return parser;
}

# pragma mark - Property Delegate Methods

- (NSNumber *)priceInDollars
{
    NSString *content = [Parser scanString:self.htmlString startTag:@"<div class=\"detail\">" endTag:@"<div class=\"infor\">"];
    NSString *priceString = [Parser scanString:content startTag:@"\"price\">$" endTag:@"&"];
    priceString = [priceString stringByReplacingOccurrencesOfString:@"," withString:@""];
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
        
        NSString *content = [Parser scanString:self.htmlString startTag:@"<div class=\"detail\">" endTag:@"<div class=\"infor\">"];
        self.name = [Parser scanString:content startTag:@"<h1>" endTag:@"</h1>"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {

        NSString *content = [Parser scanString:self.htmlString startTag:@"<div class=\"detail\">" endTag:@"<div class=\"infor\">"];
        NSString *imageString = [Parser scanString:content startTag:@"src=\"" endTag:@"\""];
        
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
