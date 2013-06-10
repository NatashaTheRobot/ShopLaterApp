//
//  Image.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/10/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product, Provider;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * externalURLString;
@property (nonatomic, retain) Product *product;
@property (nonatomic, retain) Provider *provider;

@end
