//
//  UnderarmourParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/19/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "UnderarmourParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface UnderarmourParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation UnderarmourParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    UnderarmourParser *parser = [[UnderarmourParser
                                  alloc] init];
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
    
    NSString *priceString = [Parser scanString:self.htmlString startTag:@"<span itemprop=\"price\">" endTag:@"</span>"];
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
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *urlString = [Parser scanString:self.htmlString startTag:@"<meta property=\"og:image\" content=\"" endTag:@"\""];
        
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