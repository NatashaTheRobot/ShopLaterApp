//
//  NotificationsHelper.m
//  ShopLater
//
//  Created by Rex Fatahi on 7/22/14.
//  Copyright (c) 2014 Natasha Murashev. All rights reserved.
//

#import "NotificationsHelper.h"
#import "Constants.h"

@implementation NotificationsHelper

- (void)updateToken:(NSString *)token {
    NSMutableURLRequest* updateTokenRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[ROOT_URL stringByAppendingFormat:UPDATE_USR]]];
    NSDictionary* requestDictionary = @{@"email":@"foo", @"deviceToken":token};
    NSData* dataToPost = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:nil];
    [updateTokenRequest setHTTPMethod:@"POST"];
    [updateTokenRequest setHTTPBody:dataToPost];
    [updateTokenRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [NSURLConnection sendAsynchronousRequest:updateTokenRequest queue:[NSOperationQueue mainQueue] completionHandler:nil];
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
}

@end
