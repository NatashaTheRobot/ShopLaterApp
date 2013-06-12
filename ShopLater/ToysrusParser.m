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
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "Constants.h"

@interface ToysrusParser ()

@property (strong, nonatomic) TFHpple *hpple;
@property (strong, nonatomic) CoreDataManager *coreDataManager;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

- (NSString *)getProductIdFromURLString:(NSString *)urlString;

- (NSString *)productName;
- (NSString *)productSummary;
- (Price *)productPrice;
- (Image *)productImage;

@end

@implementation ToysrusParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    ToysrusParser *parser = [[ToysrusParser alloc] init];
    parser.mobileURLString = productURLString;
    
    NSString *productId = [parser getProductIdFromURLString:productURLString];
    
    // handle error (if we cannot get the product id for some reason)
    
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
    
    for (NSString *paramPair in paramPairs) {
        NSArray *paramKeyValue = [paramPair componentsSeparatedByString:@"%3D"];
        if ([paramKeyValue[0] isEqualToString:@"productId"]) {
            return paramKeyValue[1];
        }
    }

    return nil;
}

# pragma mark - Property Delegate Methods

- (NSString *)productName
{
    if (!self.name) {
        
        NSString *namesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='priceReviewAge']/h1";
        NSArray *namesArray = [self.hpple searchWithXPathQuery:namesPath];
        self.name = [[namesArray[0] firstChild] content];
    }
    
    return self.name;
}

- (NSString *)productSummary
{
    if (!self.summary) {
        NSString *summariesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='infoPanel']/dl[@id='tabset_productPage']/dd/p";
        NSArray *summariesArray = [self.hpple searchWithXPathQuery:summariesPath];
        NSString *summary = [summariesArray[0] valueForKeyPath:@"raw"];
        NSRange rangeString;
        while ((rangeString = [summary rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
            summary = [summary stringByReplacingCharactersInRange:rangeString withString:@" "];
        
        summary = [summary stringByReplacingOccurrencesOfString:@"Product Description" withString:@""];
        self.summary = [summary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return self.summary;
}

- (Price *)productPrice
{
    if (!self.price) {
        
        NSString *pricesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='buyFind']/div[@id='buyWrapper']/div[@id='buyInterior']/div[@id='price']/ul/li[@class='retail']/span";
        NSArray *pricesArray = [self.hpple searchWithXPathQuery:pricesPath];
        NSString *priceText = [[pricesArray[0] firstChild] content];
        NSNumber *priceInDollars = [NSNumber numberWithFloat:[[priceText substringFromIndex:1] floatValue]];
        
        NSDictionary *priceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         priceInDollars, @"dollarAmount",
                                         sPriceTypeCurrent, @"type",
                                         [NSDate date], @"created_at", nil];
        self.price = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Price class])
                                                 atributesDictionary:priceDictionary];
        
    }
    
    return self.price;
}

- (Image *)productImage
{
    if (!self.image) {
        
        NSString *imagesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='leftSide']/div[@id='productView']";
        NSArray *imagesArray = [self.hpple searchWithXPathQuery:imagesPath];
        NSString *imageURLText = [[[imagesArray[0] childrenArray] valueForKeyPath:@"nodeChildArray.nodeChildArray.nodeChildArray.nodeAttributeArray"][1][1][1][0][0] valueForKey:@"nodeContent"];
        
        NSString *imageFileName = [Image imageFileNameForURL:[NSURL URLWithString:imageURLText]];
        
        NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName",
                               [NSString stringWithFormat:@"http://toysrus.com%@", imageURLText], @"externalURLString",
                                                                                    nil];
        self.image = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Image class]) atributesDictionary:imageDictionary];
        
    }
    return self.image;
}

@end