//
//  LululemonParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/15/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "LululemonParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface LululemonParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation LululemonParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    LululemonParser *parser = [[LululemonParser alloc] init];
    parser.cleanURLString = productURLString;
    parser.mobileURLString = productURLString;
    
    // handle error (if we cannot get the product id for some reason)
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:parser.cleanURLString]];
    
    parser.htmlString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    parser.coreDataManager = [CoreDataManager sharedManager];
    
    return parser;
}

# pragma mark - Property Delegate Methods

- (NSNumber *)priceInDollars
{
    NSString *priceString = [Parser scanString:self.htmlString startTag:@"class=\"amount\"" endTag:@"class=\"currency\""];
    
    priceString = [Parser scanString:priceString startTag:@"</span>" endTag:@"</span>"];
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
        
        self.name = [Parser scanString:self.htmlString startTag:@"<title>" endTag:@"|"];
        self.name = [self.name capitalizedString];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *imagePathString = [Parser scanString:self.htmlString startTag:@"pdpMainImg jqzoom" endTag:@"</a>"];
        
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
