//
//  BestbuyParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "BestbuyParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface BestbuyParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation BestbuyParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    BestbuyParser *parser = [[BestbuyParser alloc] init];
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
    NSString *priceStringNeedingEdit, *priceString;
    if ([self.htmlString containsString:@"Seller Price"]) {
        priceString = [Parser scanString:self.htmlString startTag:@"Seller Price:</span>&nbsp;<span class=\"fnt20 bold\">$" endTag:@"</"];
    } else {
        priceStringNeedingEdit = [Parser scanString:self.htmlString startTag:@"<li class=\"basePrice\">" endTag:@"</ul"];
        
        NSMutableString *mPriceString = [NSMutableString
                                           stringWithCapacity:priceStringNeedingEdit.length];
        
        NSScanner *scanner = [NSScanner scannerWithString:priceStringNeedingEdit];
        NSCharacterSet *numbers = [NSCharacterSet
                                   characterSetWithCharactersInString:@"0123456789."];
        
        while ([scanner isAtEnd] == NO) {
            NSString *buffer;
            if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
                [mPriceString appendString:buffer];
                
            } else {
                [scanner setScanLocation:([scanner scanLocation] + 1)];
            }
        }
        
        priceString = mPriceString;
        
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

        NSString *name = [Parser scanString:self.htmlString startTag:@"<head>" endTag:@"</head>"];
        self.name = [Parser scanString:name startTag:@"<title>" endTag:@"<"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *imageString;
        if ([self.htmlString containsString:@"PdpImageIMG"]) {
            imageString = [Parser scanString:self.htmlString startTag:@"PdpImageIMG" endTag:@"</li>"];
            imageString = [Parser scanString:imageString startTag:@"<img src=\"" endTag:@";"];
        } else {
            imageString = [Parser scanString:self.htmlString startTag:@"pdp-single-image" endTag:@"</div>"];
            imageString = [Parser scanString:imageString startTag:@"<img src=\"" endTag:@";"];
        }
        
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
