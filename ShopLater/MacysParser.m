//
//  MacysParser.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/13/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "MacysParser.h"
#import "CoreDataManager.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "Constants.h"
#import "NSString+ShopLaterExtension.h"

@interface MacysParser ()

@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) Price *price;
@property (strong, nonatomic) Image *image;

- (NSString *)getProductIdFromURLString:(NSString *)urlString;
- (NSString *)getProductCategoryIdFromURLString:(NSString *)urlString;
- (NSString *)getProductNameFromURLString:(NSString *)urlString;
- (NSString *)productName;
- (NSString *)productSummary;
- (Price *)productPrice;
- (Image *)productImage;

@end

@implementation MacysParser

+ (instancetype)parserWithProductURLString:(NSString *)productURLString
{
    MacysParser *parser = [[MacysParser alloc] init];
    parser.mobileURLString = productURLString;
    
    NSString *productID = [parser getProductIdFromURLString:productURLString];
    
    NSString *productCategoryID = [parser getProductCategoryIdFromURLString:productURLString];
    
    NSString *productName = [parser getProductNameFromURLString:productURLString];
    
    //handle error
    parser.cleanURLString = [NSString stringWithFormat:@"http://www1.macys.com/shop/product/%@?ID=%@&CategoryID=%@",productName, productID, productCategoryID];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:parser.cleanURLString]];
    
    parser.htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (parser.htmlString == nil) {
        parser.htmlString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    parser.coreDataManager = [CoreDataManager sharedManager];
    
    return parser;
    
}


#pragma mark - URL parse

- (NSString *)getProductIdFromURLString:(NSString *)urlString
{
    NSArray *urlComponentsProductID = [[[urlString componentsSeparatedByString:@"/"][5] componentsSeparatedByString:@"="][1] componentsSeparatedByString:@"&"];
    
    return urlComponentsProductID[0];
}

- (NSString *)getProductNameFromURLString:(NSString *)urlString
{
    NSArray *urlComponentsName = [[urlString componentsSeparatedByString:@"/"][5] componentsSeparatedByString:@"?"];
    
    return urlComponentsName[0];
}

- (NSString *)getProductCategoryIdFromURLString:(NSString *)urlString
{
    NSArray *urlComponentsCategoryID = [[[urlString componentsSeparatedByString:@"/"][5] componentsSeparatedByString:@"="][2] componentsSeparatedByString:@"#"];
    
    return urlComponentsCategoryID[0];
}

#pragma mark - Property delegate methods

- (NSNumber *)priceInDollars
{
    if ([self.htmlString containsString:@"<!-- PRICE BLOCK: Single Price -->"]) {
        
        NSString *string1NoSale = [Parser scanString:self.htmlString startTag:@"<!-- PRICE BLOCK: Single Price -->" endTag:@"<br>"];

        NSString *itemPriceNoSale = [Parser scanString:string1NoSale startTag:@"$" endTag:@"</"];
        
        return [NSNumber numberWithFloat:[itemPriceNoSale floatValue]];
        
    } else if ([self.htmlString containsString:@"<!-- PRICE BLOCK: Is at least 1 sale price -->"]) {

        NSString *string1Sale = [Parser scanString:self.htmlString startTag:@"<span>Was" endTag:@"<br>"];
        
        NSString *itemPriceSale = [Parser scanString:string1Sale startTag:@"$" endTag:@"</"];
        
        return [NSNumber numberWithFloat:[itemPriceSale floatValue]];
        
    } else {
        NSLog(@"error priceDollars Macy's delegate method");
    }
    
    return nil;
}

- (Price *)productPrice
{
    if (!self.price) {
        NSDictionary *priceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [self priceInDollars], @"dollarAmount",
                                         sPriceTypeCurrent, @"type",
                                         [NSDate date], @"created_at", nil];
        self.price = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Price class])
                                                 atributesDictionary:priceDictionary];
    }
    
    return self.price;
}

- (NSString *)productName
{
    if (!self.name) {
        NSString *itemName = [Parser scanString:self.htmlString startTag:@"itemprop=\"name\">" endTag:@"</h1>"];
        
        self.name = itemName;
    }

    return self.name;
}

- (NSString *)productSummary
{
    if (!self.summary) {
        if ([Parser scanString:self.htmlString startTag:@"itemprop=\"description\">" endTag:@"</ul>"]) {
            
            NSString *itemDescription = [Parser scanString:self.htmlString startTag:@"itemprop=\"description\">" endTag:@"</ul>"];
            
            NSRange range;
            while ((range = [itemDescription rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
                itemDescription = [itemDescription stringByReplacingCharactersInRange:range withString:@""];
            
            NSLog(@"%@", itemDescription);
        } else {
            
            NSString *itemDescription = [Parser scanString:self.htmlString startTag:@"itemprop=\"description\">" endTag:@"</div>"];
            
            NSLog(@"%@", itemDescription);
        }
    }
    
    return self.summary;
}

- (Image *)productImage
{
    if (!self.image) {
        NSString *itemImage = [Parser scanString:self.htmlString startTag:@"property=\"og:image\" content=\"" endTag:@"\" />"];
        
        NSURL *urlImage = [NSURL URLWithString:itemImage];
        
        NSString *imageFileName = [Image imageFileNameForURL:urlImage];
        
        NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName",
                                         itemImage, @"externalURLString",
                                         nil];
        self.image = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Image class]) atributesDictionary:imageDictionary];
        
    }
    
    return self.image;
}


@end
