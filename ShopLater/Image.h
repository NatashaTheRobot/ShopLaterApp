//
//  Image.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSManagedObject *product;
@property (nonatomic, retain) NSManagedObject *provider;

@end
