//
//  ShopLaterAPI.m
//  ShopLater
//
//  Created by Rex Fatahi on 7/26/14.
//  Copyright (c) 2014 Natasha Murashev. All rights reserved.
//

#import "ShopLaterAPI.h"

@implementation ShopLaterAPI

static ShopLaterAPI *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (ShopLaterAPI *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[ShopLaterAPI alloc] init];
    }
    
    return sharedInstance;
}

- (void)requestWithData:(NSData *)data type:(NSString *)requestType {
    
    NSString* urlHost = @"http://shoplater-produsus.rhcloud.com";
    
    NSString* urlTail;
    if ([requestType isEqualToString:@"token"]) {
        urlTail = @"/registeruser";
    } else if ([requestType isEqualToString:@"follow"]) {
        urlTail = @"/userupdate";
    } else if ([requestType isEqualToString:@"unfollow"]) {
        urlTail = @"/unfollowItem";
    } else {
        return;
    }

    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlHost stringByAppendingString:urlTail]]];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:data];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:nil];

}

@end
