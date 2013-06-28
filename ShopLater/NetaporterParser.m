//
//  NetaporterParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/27/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "NetaporterParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface NetaporterParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation NetaporterParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    NetaporterParser *parser = [[NetaporterParser alloc] init];
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
    
    priceString = [Parser scanString:self.htmlString startTag:@"<div id=\"price\">" endTag:@"div"];
    if ([priceString containsString:@"Now"]) {
        priceString = [Parser scanString:priceString startTag:@"Now $" endTag:@"</"];
    } else {
        priceString = [Parser scanString:priceString startTag:@"$" endTag:@"</"];
    }
    
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
        
        NSString *name = [Parser scanString:self.htmlString startTag:@"<title>" endTag:@"NET-A-PORTER.COM</title>"];
        name = [name stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
        name = [name stringByReplacingOccurrencesOfString:@"|" withString:@""];
        [name stringByReplacingOccurrencesOfString:@";" withString:@""];
        self.name = name;
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *image = [Parser scanString:self.htmlString startTag:@"image_src" endTag:@"</"];
        NSString *urlString= [Parser scanString:image startTag:@"href=\"" endTag:@"\""];
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

