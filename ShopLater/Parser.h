//
//  Parser.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/10/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Parser : NSObject

+ (id)parserWithProviderName:(NSString *)providerName productURLString:(NSString *)productURLString;

@end
