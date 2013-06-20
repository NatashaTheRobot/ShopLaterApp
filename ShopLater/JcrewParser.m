//
//  JcrewParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/18/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "JcrewParser.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "NSString+SLExtensions.h"

@interface JcrewParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

- (NSString *)getProductIdFromURLString:(NSString *)urlString;

@end

@implementation JcrewParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    JcrewParser *parser = [[JcrewParser alloc] init];
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
    NSString *priceString;
    
    if ([self.htmlString containsString:@"class=\"selected-color\">select colors"]) {
        priceString = [Parser scanString:self.htmlString startTag:@"<DIV class=\"selected-color\">select colors $" endTag:@"\""];
    } else if ([self.htmlString containsString:@" full-price  "]) {
        priceString = [Parser scanString:self.htmlString startTag:@"<SPAN class=\" full-price  \">$" endTag:@"</SPAN>"];
    } else {
        priceString = [Parser scanString:self.htmlString startTag:@"<DIV class=\"spaceTB10 white\">$" endTag:@"</DIV>"];
    }
//    if ([price containsString:@"now"]) {
//        priceString = [Parser scanString:price startTag:@"now $" endTag:@"</"];
//    } else {
//        priceString = [Parser scanString:price startTag:@"$" endTag:@"<BR"];
//    }
    
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

        self.name = [Parser scanString:self.htmlString startTag:@"<TITLE>" endTag:@" - "];    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *image = [Parser scanString:self.htmlString startTag:@"carousel_img" endTag:@"</div>"];
        NSString *urlString = [Parser scanString:image startTag:@"src=\"" endTag:@"\""];
        urlString = [NSString stringWithFormat:@"http://m.jcrew.com%@", urlString];
        
        NSData *data2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if (data2.length == 0) {
            urlString = [Parser scanString:self.htmlString  startTag:@"productgalleryPage('" endTag:@"\'"];
            urlString = [urlString stringByReplacingOccurrencesOfString:@";" withString:@""];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"amp" withString:@""];
        }
        
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
