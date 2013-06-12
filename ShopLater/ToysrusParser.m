//
//  ToysrusParser.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/9/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ToysrusParser.h"
#import "Price.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"

@interface ToysrusParser ()

@property (strong, nonatomic) NSString *htmlString;
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
    NSString *productId = [parser getProductIdFromURLString:productURLString];
    
    // handle error (if we cannot get the product id for some reason)
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.toysrus.com/product/index.jsp?productId=%@", productId]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    parser.htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

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

- (Price *)productPrice
{
   
    if (!self.price) {
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:self.htmlString];
        
        scanner.scanLocation = 0;
        
        NSString *startTag = @"<li class=\"retail\">";
        NSString *endTag = @"</li>";
        
        NSString *priceString = nil;
        
        
        [scanner scanUpToString:startTag intoString:nil];
        scanner.scanLocation += [startTag length];
        [scanner scanUpToString:endTag intoString:&priceString];
        
        
        scanner = [[NSScanner alloc] initWithString:priceString];
        startTag = @"&#036;";
        endTag = @"</span>";
        
        [scanner scanUpToString:startTag intoString:nil];
        scanner.scanLocation += [startTag length];
        [scanner scanUpToString:endTag intoString:&priceString];
  
        
        NSNumber *priceInDollars = [NSNumber numberWithFloat:[priceString floatValue]];
        
        NSDictionary *priceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         priceInDollars, @"dollarAmount",
                                         @"current", @"type",
                                         [NSDate date], @"created_at", nil];
        self.price = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Price class])
                                                 atributesDictionary:priceDictionary];
        
    }
    
    return self.price;
}


- (NSString *)productName
{
    
    if (!self.name) {
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:self.htmlString];
                
        NSString *startTag = @"<div id=\"priceReviewAge\">";
        NSString *endTag = @"<h3>";
        
        NSString *nameString = nil;
        
        
        [scanner scanUpToString:startTag intoString:nil];
        scanner.scanLocation += [startTag length];
        [scanner scanUpToString:endTag intoString:&nameString
         ];
        
        
        scanner = [[NSScanner alloc] initWithString:nameString];
        
        startTag = @"<h1>";
        endTag = @"</h1>";
        
        [scanner scanUpToString:startTag intoString:&nameString];
        scanner.scanLocation += [startTag length];
        [scanner scanUpToString:endTag intoString:&nameString];
        
        self.name = nameString;
    }
    
    return self.name;
}

- (NSString *)productSummary
{
    if (!self.summary) {
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:self.htmlString];
        
        NSString *startTag = @"<label>Product Description</label>";
        NSString *endTag = @"<p>";
        
        NSString *descriptionString = nil;
        
        
        [scanner scanUpToString:startTag intoString:nil];
        scanner.scanLocation += [startTag length];
        [scanner scanUpToString:endTag intoString:&descriptionString
         ];
        
        
        startTag = @"<br />";
        endTag = @"<br />";
        
        scanner = [[NSScanner alloc] initWithString:descriptionString];
        [scanner scanUpToString:startTag intoString:nil];
        scanner.scanLocation += [startTag length];
        [scanner scanUpToString:endTag intoString:&descriptionString
         ];
        
        self.summary = descriptionString;
        
        
    }
    return self.summary;
}



- (Image *)productImage
{
    if (!self.image) {
                
        NSScanner *scanner = [[NSScanner alloc] initWithString:self.htmlString];
        
        NSString *startTag = @"dtmTag.dtmc_prod_img =";
        NSString *endTag = @";";
        
        NSString *imageString = nil;

        
        [scanner scanUpToString:startTag intoString:nil];
        scanner.scanLocation += [startTag length];
        [scanner scanUpToString:endTag intoString:&imageString
         ];
        
        scanner = [[NSScanner alloc] initWithString:imageString];
        startTag = @"\"";
        endTag = @"\"";
        
        [scanner scanUpToString:startTag intoString:nil];
        scanner.scanLocation += [startTag length];
        [scanner scanUpToString:endTag intoString:&imageString
         ];
        
        NSLog(@"%@", imageString);
        
        NSString *urlString = [NSString stringWithFormat:@"http://toysrus.com%@", imageString];
        
        NSURL *urlImage = [NSURL URLWithString:urlString];
        
    
        
        NSString *imageFileName = [Image imageFileNameForURL:urlImage];
        
        NSDictionary *imageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFileName, @"fileName",
                               urlString, @"externalURLString",
                                                                                    nil];
        self.image = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Image class]) atributesDictionary:imageDictionary];
        
    }
    return self.image;
}

@end