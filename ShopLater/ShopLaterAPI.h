//
//  ShopLaterAPI.h
//  ShopLater
//
//  Created by Rex Fatahi on 7/26/14.
//  Copyright (c) 2014 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopLaterAPI : NSObject

+ (ShopLaterAPI *)sharedInstance;
- (void)requestWithData:(NSData *)data type:(NSString *)requestType;

@end
