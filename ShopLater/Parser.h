//
//  Parser.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/10/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParserDelegate.h"

@interface Parser : NSObject

+ (instancetype)parserWithProviderName:(NSString *)providerName productURLString:(NSString *)productURLString;

@property (strong, nonatomic) id<ParserDelegate> delegate;

@end
