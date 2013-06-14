//
//  Identifier.h
//  ShopLater
//
//  Created by Reza Fatahi on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Provider;

@interface Identifier : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Provider *provider;

@end
