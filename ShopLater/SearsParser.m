//
//  SearsParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/17/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "SearsParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface SearsParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation SearsParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    SearsParser *parser = [[SearsParser alloc] init];
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

- (NSString *)getProductIdFromURLString:(NSString *)urlString
{
    return [Parser scanString:urlString startTag:@"Details/" endTag:@"?"];
}

# pragma mark - Property Delegate Methods

- (NSNumber *)priceInDollars
{
    NSString* priceString;
    NSString* price = [Parser scanString:self.htmlString startTag:@"<span id=\"salePrice\"" endTag:@"</div>"];
    if ([price containsString:@"*"]) {
        priceString = [Parser scanString:price startTag:@">" endTag:@"*"];
    } else {
        priceString = [Parser scanString:price startTag:@">" endTag:@"</span>"];
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
        NSString* name = [Parser scanString:self.htmlString startTag:@"<div id=\"productName\" class=\"spu-margin\">" endTag:@"</div>"];
        self.name = [Parser scanString:name startTag:@"<b>" endTag:@"</b>"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        
        NSString *urlString = [Parser scanString:self.htmlString startTag:@"productgalleryPage('" endTag:@"?"];

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
