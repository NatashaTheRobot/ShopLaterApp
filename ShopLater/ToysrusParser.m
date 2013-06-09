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

@interface ToysrusParser ()

@property (strong, nonatomic) TFHpple *hpple;

@end

@implementation ToysrusParser

+ (ToysrusParser *)parserWithProductID:(NSString *)productID
{
    ToysrusParser *parser = [self init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.toysrus.com/product/index.jsp?productId=%@", productID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    parser.hpple = [TFHpple hppleWithHTMLData:data];
    
    return parser;
}

- (NSString *)productName
{
    NSString *namesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='priceReviewAge']/h1";
    NSArray *namesArray = [self.hpple searchWithXPathQuery:namesPath];
    NSString *name = [[namesArray[0] firstChild] content];
    return name;
}

//- (NSMutableDictionary *)productPrice
//{
//    NSString *pricesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='buyFind']/div[@id='buyWrapper']/div[@id='buyInterior']/div[@id='price']/ul/li/span";
//    NSArray *pricesArray = [self.hpple searchWithXPathQuery:pricesPath];
//    NSString *price = [[pricesArray[0] firstChild] content];
//    
////    NSDictionary *priceDictionary = [NSDictionary ]
////    [CoreDataManager sharedManager] createPriceWithDictionary:<#(NSDictionary *)#>
//    
//    // return nsmutable dictionary
//}

- (void)parseProductWithID:(NSString *)productID
{

//    NSURL* toysrusURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.toysrus.com/product/index.jsp?productId=%@", productID]];
//    
//    NSData *toysrusData = [NSData dataWithContentsOfURL:toysrusURL];
//    
//    // create HPPLE parse object with NSData object
//    TFHpple* hpple = [TFHpple hppleWithHTMLData:toysrusData];

    // NAME
//    NSString* toysrusProductNamesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='priceReviewAge']/h1";
//    NSArray* toysrusProductNamesArray = [hpple searchWithXPathQuery:toysrusProductNamesPath];
//    NSString* toysrusProductName = [[toysrusProductNamesArray[0] firstChild] content];
    
    // PRICE
//    NSString* toysrusProductPricesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='rightSide']/div[@id='buyFind']/div[@id='buyWrapper']/div[@id='buyInterior']/div[@id='price']/ul/li/span";
//    NSArray* toysrusProductsPriceArray = [hpple searchWithXPathQuery:toysrusProductPricesPath];
//    NSString* toysrusProductPrice = [[toysrusProductsPriceArray[0] firstChild] content];
//    
//    // SUMMARY DESCRIPTION
//    NSString* toysrusProductDescriptionsPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='infoPanel']/dl[@id='tabset_productPage']/dd/p";
//    NSArray* toysrusProductDescriptionsArray = [self.hpple searchWithXPathQuery:toysrusProductDescriptionsPath];
//    NSString* toysrusProductDescription = [toysrusProductDescriptionsArray[0] valueForKeyPath:@"raw"];
//    NSRange rangeString;
//    while ((rangeString = [toysrusProductDescription rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
//        toysrusProductDescription = [toysrusProductDescription stringByReplacingCharactersInRange:rangeString withString:@" "];
//    
//    toysrusProductDescription = [toysrusProductDescription stringByReplacingOccurrencesOfString:@"Product Description" withString:@""];
//    toysrusProductDescription = [toysrusProductDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    // IMAGE
//    
//    NSString* toysrusProductImagesPath = @"//div[@id='wrapper']/div[@id='container']/div[@id='productPanel']/div[@id='leftSide']/div[@id='productView']";
//    NSArray* toysrusProductImagesArray = [self.hpple searchWithXPathQuery:toysrusProductImagesPath];
//    NSString* toysrusProductImage = [[[toysrusProductImagesArray[0] childrenArray] valueForKeyPath:@"nodeChildArray.nodeChildArray.nodeChildArray.nodeAttributeArray"][1][1][1][0][0] valueForKey:@"nodeContent"];
//    
//    
}

@end