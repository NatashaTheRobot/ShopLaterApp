//
//  DupontregistryParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/15/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "DupontregistryParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface DupontregistryParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation DupontregistryParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    DupontregistryParser *parser = [[DupontregistryParser alloc] init];
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
    NSString *priceString = [Parser scanString:self.htmlString startTag:@"Price:</strong>" endTag:@"<br />"];
    priceString = [Parser scanString:priceString startTag:@"$" endTag:@""];
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
        
        NSString* fullName = [Parser scanString:self.htmlString startTag:@"Make" endTag:@"Mileage"];
        NSString* firstName = [Parser scanString:fullName startTag:@"</strong>" endTag:@"<br />"];
        NSString* lastName = [Parser scanString:fullName startTag:@"Model:</strong>" endTag:@"<br />"];
        
        self.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *imagePathString = [Parser scanString:self.htmlString startTag:@"<div id=\"imagegallery\">" endTag:@"width"];
        
        NSString *imageString = [Parser scanString:imagePathString startTag:@"<img src=\"" endTag:@"\""];
        
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
