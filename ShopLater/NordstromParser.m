//
//  NordstromParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/17/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "NordstromParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface NordstromParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

- (NSString *)getProductIdFromURLString:(NSString *)urlString;

@end

@implementation NordstromParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    NordstromParser *parser = [[NordstromParser alloc] init];
    parser.mobileURLString = productURLString;
    
    NSString *productId = [parser getProductIdFromURLString:productURLString];
    
    // handle error (if we cannot get the product id for some reason)
    parser.cleanURLString = [NSString stringWithFormat:@"http://shop.nordstrom.com/s/%@", productId];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:parser.cleanURLString]];
    parser.htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (parser.htmlString == nil) {
        parser.htmlString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    parser.coreDataManager = [CoreDataManager sharedManager];
    
    return parser;
}

- (NSString *)getProductIdFromURLString:(NSString *)urlString
{
    return [Parser scanString:urlString startTag:@"Details/" endTag:@"?"];
}

# pragma mark - Property Delegate Methods

- (NSNumber *)priceInDollars
{
    NSString* priceString;
    NSString* totalPrice = [Parser scanString:self.htmlString startTag:@"id=\"itemNumberPrice\"" endTag:@"</div>"];
    if ([totalPrice containsString:@"price sale"]) {
        //path to price sale
        priceString = [Parser scanString:totalPrice startTag:@"Now: $" endTag:@"</span>"];
    } else {
        priceString = [Parser scanString:totalPrice startTag:@"<span class=\"price regular\"" endTag:@"span"];
        priceString = [Parser scanString:priceString startTag:@"$" endTag:@"<"];
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
        
        self.name = [Parser scanString:self.htmlString startTag:@"<title>" endTag:@"|"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *imageString = [Parser scanString:self.htmlString startTag:@"fashion-photo-wrapper" endTag:@"</div>"];
        
        NSString *urlString = [Parser scanString:imageString startTag:@"src=\"" endTag:@"\""];
        
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