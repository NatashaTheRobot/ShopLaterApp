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

- (void)postToAPI
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:sAPIBaseURL]];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[sAPIKey, sAPISecret, self.url, self.provider.name]
                                                           forKeys:@[@"api_key", @"api_secret", @"url", @"provider"]];
       
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                         path:@"/products"
                                                                   parameters:parameters
                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                        nil;
                                                    }];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SUCCESS! %@", operation);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FAILURE %@", error.description);
    }];
    
    [httpClient enqueueHTTPRequestOperation:requestOperation];
}

@end
