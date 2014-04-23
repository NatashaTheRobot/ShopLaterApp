//
//  TopshopParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/20/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "TopshopParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface TopshopParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

@end

@implementation TopshopParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    TopshopParser *parser = [[TopshopParser alloc] init];
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
    NSString* priceHTMLString = [Parser scanString:self.htmlString startTag:@"Price:" endTag:@"\""];
    priceHTMLString = [Parser scanString:priceHTMLString startTag:@";$" endTag:@"<"];
    if ([priceHTMLString containsString:@" "]) {
        priceHTMLString = [priceHTMLString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]][0];
    }
    
    NSLog(@"priceHTMLString = %@", priceHTMLString);
    
    
    return [NSNumber numberWithFloat:[priceHTMLString floatValue]];
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
        
        self.name = [Parser scanString:self.htmlString startTag:@"<TITLE>" endTag:@"</TITLE>"];
    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *image = [Parser scanString:self.htmlString startTag:@"class=\"unImgWidth\" src=\"" endTag:@"\""];;
        NSLog(@"image = %@", image);
        NSURL *urlImage = [NSURL URLWithString:image];
        NSString *imageFileName = [Image imageFileNameForURL:urlImage];
        NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName",
                                         image, @"externalURLString",
                                         nil];
        self.image = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Image class]) attributesDictionary:imageDictionary];
        
    }
    return self.image;
}

@end


