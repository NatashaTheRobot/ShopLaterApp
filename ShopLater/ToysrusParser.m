//
//  ToysrusParser.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/9/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ToysrusParser.h"
#import "TFHpple.h"
#import "Price.h"
#import "Image.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"

@interface ToysrusParser ()

@property (strong, nonatomic) TFHpple *hpple;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@end

@implementation ToysrusParser

+ (ToysrusParser *)parserWithProductURLString:(NSString *)productURLString
{
    ToysrusParser *parser = [self init];
    NSString *productId = [parser getProductIdFromURLString:productURLString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.toysrus.com/product/index.jsp?productId=%@", productId]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    parser.hpple = [TFHpple hppleWithHTMLData:data];
    parser.coreDataManager = [CoreDataManager sharedManager];
    
    return parser;
}

- (NSString *)getProductIdFromURLString:(NSString *)urlString
{
    NSArray *urlComponents = [urlString componentsSeparatedByString:@"jsp%3F"];
    NSArray *paramPairs = [urlComponents[1] componentsSeparatedByString:@"&"];
    
    [paramPairs enumerateObjectsUsingBlock:^(NSString *paramPair, NSUInteger idx, BOOL *stop) {
        NSArray *paramKeyValue = [paramPair componentsSeparatedByString:@"%3D"];
    }];
    
//    [paramPairs enumerateObjectsUsingBlock:^(NSString *paramPair, NSUInteger idx, BOOL *stop) {
//        NSArray *paramKeyValue = [paramPair componentsSeparatedByString:@"%3D"];
//        if ([paramKeyValue[0] isEqualToString:@"productId"]) {
//            return paramKeyValue[1];
//        }
//    }];

    
    return nil;
}

//- (void)parseURL
//{
//    NSArray *urlComponents = [self.productURLString componentsSeparatedByString:@"jsp%3F"];
//
//    NSArray *paramPairs = [urlComponents[1] componentsSeparatedByString:@"&"];
//
//    NSMutableDictionary *urlParamsDictionary = [[NSMutableDictionary alloc] init];
//
//    [paramPairs enumerateObjectsUsingBlock:^(NSString *paramPair, NSUInteger idx, BOOL *stop) {
//        NSArray *paramKeyValue = [paramPair componentsSeparatedByString:@"%3D"];
//        if ([paramKeyValue[0] isEqualToString:@"productId"]) {
//            NSLog(@"product id = %@", paramKeyValue[1]);
//            return;
//        }
//    }];
//}

- (NSString *)productName
{
    NSString *namesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='priceReviewAge']/h1";
    NSArray *namesArray = [self.hpple searchWithXPathQuery:namesPath];
    NSString *name = [[namesArray[0] firstChild] content];
    return name;
}

- (NSString *)productSummary
{
    NSString *summariesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='infoPanel']/dl[@id='tabset_productPage']/dd/p";
    NSArray *summariesArray = [self.hpple searchWithXPathQuery:summariesPath];
    NSString *summary = [summariesArray[0] valueForKeyPath:@"raw"];
    NSRange rangeString;
    while ((rangeString = [summary rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        summary = [summary stringByReplacingCharactersInRange:rangeString withString:@" "];
    
    summary = [summary stringByReplacingOccurrencesOfString:@"Product Description" withString:@""];
    summary = [summary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return summary;
}

- (Price *)productPrice
{
    NSString *pricesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='buyFind']/div[@id='buyWrapper']/div[@id='buyInterior']/div[@id='price']/ul/li/span";
    NSArray *pricesArray = [self.hpple searchWithXPathQuery:pricesPath];
    NSString *priceText = [[pricesArray[0] firstChild] content];
    NSNumber *priceInDollars = [NSNumber numberWithFloat:[[priceText substringFromIndex:1] floatValue]];
    
    NSDictionary *priceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:priceInDollars, @"dollarAmount", nil];
    Price *price = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Price class])
                                               atributesDictionary:priceDictionary];
    
    return price;
}

- (Image *)productImage
{
    NSString *imagesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='leftSide']/div[@id='productView']";
    NSArray *imagesArray = [self.hpple searchWithXPathQuery:imagesPath];
    NSString *imageURLText = [[[imagesArray[0] childrenArray] valueForKeyPath:@"nodeChildArray.nodeChildArray.nodeChildArray.nodeAttributeArray"][1][1][1][0][0] valueForKey:@"nodeContent"];

    NSString *imageFileName = [Image downloadImageFromURL:[NSURL URLWithString:imageURLText]];

    NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName", nil];
    Image *image = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Image class]) atributesDictionary:imageDictionary];
    
    return image;
}

@end