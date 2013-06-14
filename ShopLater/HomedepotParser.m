//
//  HomedepotParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "HomedepotParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"

@interface HomedepotParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

- (NSString *)getProductIdFromURLString:(NSString *)urlString;

@end

@implementation HomedepotParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    HomedepotParser *parser = [[HomedepotParser alloc] init];
    parser.mobileURLString = productURLString;
    
    NSString *productId = [parser getProductIdFromURLString:productURLString];
    
    // handle error (if we cannot get the product id for some reason)
    parser.cleanURLString = [NSString stringWithFormat:@"http://www.homedepot.com/p/%@", productId];
    
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
    NSString *paramsString = [Parser scanString:urlString startTag:@"/p/" endTag:@""];
    
    return [Parser scanString:paramsString startTag:@"/" endTag:@"/"];
}

# pragma mark - Property Delegate Methods

- (NSNumber *)priceInDollars
{
   NSString *priceString = [Parser scanString:self.htmlString startTag:@" itemprop=\"price\"> $" endTag:@"</span>"];
    
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
                                                 atributesDictionary:priceDictionary];
        
    }
    
    return self.price;
}


- (NSString *)productName
{
    
    if (!self.name) {
        
        self.name = [Parser scanString:self.htmlString startTag:@"<span itemprop=\"name\">" endTag:@"</span>"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *imageString = [Parser scanString:self.htmlString startTag:@"class=\"product_mainimg\"" endTag:@"</div>"];
        imageString = [Parser scanString:imageString startTag:@"itemprop=\"image\"" endTag:@"</a>"];
        
        NSString *urlString = [Parser scanString:imageString startTag:@"src=\"" endTag:@"\""];
        
        NSURL *urlImage = [NSURL URLWithString:urlString];
        
        NSString *imageFileName = [Image imageFileNameForURL:urlImage];
        
        NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName",
                                         urlString, @"externalURLString",
                                         nil];
        self.image = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Image class]) atributesDictionary:imageDictionary];
        
    }
    return self.image;
}

@end
