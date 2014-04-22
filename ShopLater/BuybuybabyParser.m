//
//  BuybuybabyParse.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/17/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "BuybuybabyParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface BuybuybabyParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation BuybuybabyParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{    
    BuybuybabyParser *parser = [[BuybuybabyParser alloc] init];
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
    NSString *content = [Parser scanString:self.htmlString startTag:@"<h2 id=\"prodPrice\">" endTag:@"</h2>"];
    if ([content containsString:@"<span>"]) {
        content = [Parser scanString:content startTag:@"<span>" endTag:@"</span>"];
    }
    content = [content componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]][0];
    content = [content stringByReplacingOccurrencesOfString:@"," withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"$" withString:@""];
    
    NSLog(@"content price = %@", content);
    return [NSNumber numberWithFloat:[content floatValue]];
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
        
        NSString *content = [Parser scanString:self.htmlString startTag:@"<h1>" endTag:@"</h1>"];
        self.name = content;
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {

        NSString *content = [Parser scanString:self.htmlString startTag:@"<figure><img src=\"" endTag:@"\" "];
        content = [NSString stringWithFormat:@"http:%@", content];
        
        NSLog(@"content image = %@", content);
        
        NSURL *urlImage = [NSURL URLWithString:content];
        
        NSString *imageFileName = [Image imageFileNameForURL:urlImage];
        
        NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName",
                                         content, @"externalURLString",
                                         nil];
        self.image = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Image class]) attributesDictionary:imageDictionary];
        
    }
    return self.image;
}

@end
