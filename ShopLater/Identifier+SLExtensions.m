//
//  Identifier+SLExtensions.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "Identifier+SLExtensions.h"
#import "CoreDataManager.h"

@implementation Identifier (SLExtensions)

+ (NSSet *)identifiersWithNames:(NSArray *)names
{
    NSMutableSet *identifierSet = [[NSMutableSet alloc] init];
    
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *identiferDictionary = [NSDictionary dictionaryWithObject:name forKey:@"name"];
        
        Identifier *identifier = [[CoreDataManager sharedManager] createEntityWithClassName:NSStringFromClass([Identifier class])
                                                                        atributesDictionary:identiferDictionary];

        [identifierSet addObject:identifier];
        
    }];
    
    return [NSSet setWithSet:identifierSet];
}

@end
