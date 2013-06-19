//
//  Parser.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/10/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Parser.h"

@implementation Parser

+ (id)parserWithProviderName:(NSString *)providerName productURLString:(NSString *)productURLString
{
    Parser *parser = [[Parser alloc] init];

    NSString *parserName = [NSString stringWithFormat:@"%@Parser", [providerName capitalizedString]];
    Class providerParser = NSClassFromString(parserName);

    parser.delegate = [providerParser parserWithProductURLString:productURLString];
    
    return parser;
}


+ (NSString *)scanString:(NSString *)string startTag:(NSString *)startTag endTag:(NSString *)endTag
{
    
    NSString* scanString = @"";
    
    if (string.length > 0) {
        
        NSScanner* scanner = [[NSScanner alloc] initWithString:string];
        
        @try {
            [scanner scanUpToString:startTag intoString:nil];
            scanner.scanLocation += [startTag length];
            [scanner scanUpToString:endTag intoString:&scanString];
        }
        @catch (NSException *exception) {
            return nil;
        }
        @finally {
            return scanString;
        }
    
    }

    
    return scanString;
    
}


@end
