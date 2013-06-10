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

+ (ToysrusParser *)parserWithProductID:(NSString *)productID
{
    ToysrusParser *parser = [self init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.toysrus.com/product/index.jsp?productId=%@", productID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    parser.hpple = [TFHpple hppleWithHTMLData:data];
    parser.coreDataManager = [CoreDataManager sharedManager];
    
    return parser;
}

- (NSString *)productName
{
    NSString *namesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='priceReviewAge']/h1";
    NSArray *namesArray = [self.hpple searchWithXPathQuery:namesPath];
    NSString *name = [[namesArray[0] firstChild] content];
    return name;
}

- (Price *)productPrice
{
    NSString *pricesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='buyFind']/div[@id='buyWrapper']/div[@id='buyInterior']/div[@id='price']/ul/li/span";
    NSArray *pricesArray = [self.hpple searchWithXPathQuery:pricesPath];
    NSString *priceText = [[pricesArray[0] firstChild] content];
    NSNumber *priceInDollars = [NSNumber numberWithFloat:[[priceText substringFromIndex:1] floatValue]];
    
    NSDictionary *priceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:priceInDollars, @"dollarAmount", nil];
    Price *price = [self.coreDataManager createPriceWithDictionary:priceDictionary];
    
    return price;
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

- (Image *)productImage
{
    NSString *imagesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='leftSide']/div[@id='productView']";
    NSArray *imagesArray = [self.hpple searchWithXPathQuery:imagesPath];
    NSString *imageURLText = [[[imagesArray[0] childrenArray] valueForKeyPath:@"nodeChildArray.nodeChildArray.nodeChildArray.nodeAttributeArray"][1][1][1][0][0] valueForKey:@"nodeContent"];

    NSString *imageFileName = [Image downloadImageFromURL:[NSURL URLWithString:imageURLText]];

    NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName", nil];
    Image *image = [self.coreDataManager createImageWithDictionary:imageDictionary];
    
    return image;
}

@end