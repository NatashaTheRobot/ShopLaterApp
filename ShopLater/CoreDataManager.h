//
//  CoreDataManager.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;
@class Price;
@class Provider;
@class Product;

@interface CoreDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (CoreDataManager *)sharedManager;

- (void)saveDataInManagedContextUsingBlock:(void (^)(BOOL saved, NSError *error))savedBlock;

- (NSFetchedResultsController *)fetchManagedObjectsWithClassName:(NSString *)className
                                             withSortDescriptors:(NSArray *)sortDescriptors;
- (id)createEntityWithClassName:(NSString *)className atributesDictionary:(NSDictionary *)attributesDictionary;

@end
