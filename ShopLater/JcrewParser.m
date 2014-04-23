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
    NSString *priceString = [Parser scanString:self.htmlString startTag:@"lpAddVars('page','ProductValue','" endTag:@"'"];
    NSLog(@"priceString = %@", priceString);
//    if ([price containsString:@"now"]) {
//        priceString = [Parser scanString:price startTag:@"now $" endTag:@"</"];
//    } else {
//        priceString = [Parser scanString:price startTag:@"$" endTag:@"<BR"];
//    }
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

        self.name = [Parser scanString:self.htmlString startTag:@"<TITLE>" endTag:@" - "];    }
    
    return self.name;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *content = [Parser scanString:self.htmlString startTag:@"class=\"prod-main-img\" src=\"" endTag:@"\""];
        
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
