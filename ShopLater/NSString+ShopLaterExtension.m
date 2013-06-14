//
//  NSString+ShopLaterExtension.m
//  Parsers
//
//  Created by Reza Fatahi on 6/13/13.
//  Copyright (c) 2013 Rex Fatahi. All rights reserved.
//

#import "NSString+ShopLaterExtension.h"

@implementation NSString (ShopLaterExtension)

- (BOOL) containsString: (NSString*) substring
{
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

@end
