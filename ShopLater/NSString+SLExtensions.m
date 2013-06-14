//
//  NSString+SLExtensions.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "NSString+SLExtensions.h"

@implementation NSString (SLExtensions)

- (BOOL)containsString:(NSString*)substring
{
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}

@end
