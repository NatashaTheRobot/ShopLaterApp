//
//  Product+SLExtensions.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Product+SLExtensions.h"
#import "Image+SLExtensions.h"
#import "Price+SLExtensions.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Constants.h"
#import "CoreDataManager.h"

@implementation Product (SLExtensions)

- (UIImage *)image
{
    return [(Image *)[self.images anyObject] image];
}

- (Price *)priceWithType:(NSString *)type
{
    NSPredicate *priceFilter = [NSPredicate predicateWithFormat:@"type == %@", type];
    return [[self.prices filteredSetUsingPredicate:priceFilter] anyObject];
}

- (NSString *)formattedPriceWithType:(NSString *)type
{
    Price *price = [self priceWithType:type];
    return [Price formattedPriceFromNumber:price.dollarAmount];
}

- (NSNumber *)currentWishPriceDifference
{
    CGFloat currentPrice = [[self priceWithType:sPriceTypeCurrent].dollarAmount floatValue];
    CGFloat wishPrice = [[self priceWithType:sPriceTypeWish].dollarAmount floatValue];
    CGFloat priceDifference = currentPrice - wishPrice;
    
    return [NSNumber numberWithFloat:priceDifference];
}

- (void)postToAPI
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:sAPIBaseURL]];
    
    NSString *wishPrice = [NSString stringWithFormat:@"%@", [self priceWithType:sPriceTypeWish].dollarAmount ];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[sAPIKey, sAPISecret, self.url, self.provider.name, wishPrice]
                                                           forKeys:@[@"api_key", @"api_secret", @"url", @"provider", @"wish_price"]];
       
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                         path:@"/products"
                                                                   parameters:parameters
                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                        nil;
                                                    }];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *productResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        self.externalId = productResponse[@"id"];
        [[CoreDataManager sharedManager] saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE %@", error.description);
    }];
    
    [httpClient enqueueHTTPRequestOperation:requestOperation];
}

@end
