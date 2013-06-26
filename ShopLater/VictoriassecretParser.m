//
//  VictoriassecretParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/19/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "VictoriassecretParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface VictoriassecretParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation VictoriassecretParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    VictoriassecretParser *parser = [[VictoriassecretParser alloc] init];
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
    NSString* priceHTMLString = [Parser scanString:self.htmlString startTag:@" <p class=\"price\">" endTag:@"</section>"];
    
    NSString *priceString;
    if ([priceHTMLString containsString:@"Clearance"]) {
        priceString = [Parser scanString:priceHTMLString startTag:@"Clearance $" endTag:@"</em>"];
    } else if ([priceHTMLString containsString:@"Special"]) {
        priceString = [Parser scanString:priceHTMLString startTag:@"$" endTag:@"or"];
        if ([priceString containsString:@"</em>"]) {
            priceString = [Parser scanString:priceHTMLString startTag:@"" endTag:@"</em>"];
        }
    } else if ([priceHTMLString containsString:@"Sale"]) {
        priceString = [Parser scanString:priceHTMLString startTag:@"Sale $" endTag:@"</em>"];
    } else if ([priceHTMLString containsString:@"price"]) {
        priceString = [Parser scanString:priceHTMLString startTag:@"price" endTag:@"<br>"];
    }  else if ([priceHTMLString containsString:@"Print"]) {
        if ([[priceHTMLString componentsSeparatedByString:@","][0] containsString:@"Solids"]) {
            priceString = [Parser scanString:priceHTMLString startTag:@"$" endTag:@"<br>"];
        } else if ([priceHTMLString containsString:@"Print, $"]){
            priceString = [Parser scanString:priceHTMLString startTag:@"Print, $" endTag:@"</em>"];
            if ([priceString containsString:@"<br>"]) {
                priceString = [priceString componentsSeparatedByString:@"<br>"][0];
            }
        }
        else {
            priceString = [Parser scanString:priceHTMLString startTag:@"$" endTag:@"<br>"];
        }
    } else {
        priceString = [Parser scanString:priceHTMLString startTag:@"$" endTag:@"<br>"];
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
        
        self.name = [Parser scanString:self.htmlString startTag:@"<title>" endTag:@"</title>"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *image = [Parser scanString:self.htmlString startTag:@"mainContentOfPage" endTag:@"div class=\"name\""];
        NSString *urlString = [Parser scanString:image startTag:@"src=\"" endTag:@"\""];
        urlString = [urlString componentsSeparatedByString:@"-"][1];
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
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


