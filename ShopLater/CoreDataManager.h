//
//  CoreDataManager.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (CoreDataManager *)sharedManager;

- (BOOL)saveDataInManagedContext;

#pragma mark - Products
- (BOOL)productsExist;

#pragma mark - Providers
- (BOOL)providersExist;
- (void)createProviderWithName:(NSString *)name;

@end
