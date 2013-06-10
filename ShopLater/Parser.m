//
//  Parser.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/10/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Parser.h"
#import "ParserDelegate.h"

@implementation Parser

+ (id)parserWithProviderName:(NSString *)providerName productURLString:(NSString *)productURLString
{
    NSString *parserName = [NSString stringWithFormat:@"%@Parser", [providerName capitalizedString]];
    Class providerParser = NSClassFromString(parserName);
    id <ParserDelegate> parser = [providerParser parserWithProductURLString:productURLString];
    return parser;
}

@end
