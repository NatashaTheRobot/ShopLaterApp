//
//  BedbathbeyondParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/15/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "BedbathbeyondParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface BedbathbeyondParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

- (NSString *)getProductIdFromURLString:(NSString *)urlString;

@end

@implementation BedbathbeyondParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    BedbathbeyondParser *parser = [[BedbathbeyondParser alloc] init];
    parser.mobileURLString = productURLString;
    
    NSString *productId = [parser getProductIdFromURLString:productURLString];
    
    // handle error (if we cannot get the product id for some reason)
    parser.cleanURLString = [NSString stringWithFormat:@"http://www.bedbathandbeyond.com/product.asp?SKU=%@", productId];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:parser.cleanURLString]];
    
    parser.htmlString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    parser.coreDataManager = [CoreDataManager sharedManager];
    
    return parser;
}

- (NSString *)getProductIdFromURLString:(NSString *)urlString
{
    return [Parser scanString:urlString startTag:@"itemId=" endTag:@"&categoryId"];
}

# pragma mark - Property Delegate Methods

- (NSNumber *)priceInDollars
{
    NSString *priceString = [Parser scanString:self.htmlString startTag:@"name=\"price0\" id=\"price0\" value=\"" endTag:@"\">"];
    
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
        
        self.name = [Parser scanString:self.htmlString startTag:@"class=\"producttitle\">" endTag:@"</h1>"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *imagePathString = [Parser scanString:self.htmlString startTag:@"ppimgandinfo" endTag:@"</a>"];
        
        imagePathString = [Parser scanString:imagePathString startTag:@"<img src=\"" endTag:@"\""];
        
        NSString *imageString = [NSString stringWithFormat:@"http://www.bedbathandbeyond.com/%@", imagePathString];
        
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
