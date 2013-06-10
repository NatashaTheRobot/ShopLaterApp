//
//  CoreDataManager.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "CoreDataManager.h"
#import "Product.h"
#import "Provider.h"
#import "Image.h"
#import "Price.h"

@interface CoreDataManager ()

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)setupManagedObjectContext;

@end


@implementation CoreDataManager

static CoreDataManager *coreDataManager;

+ (CoreDataManager *)sharedManager
{
    if (!coreDataManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            coreDataManager = [[CoreDataManager alloc] init];
        });
    
    }
    
    return coreDataManager;
}

#pragma mark - setup

- (id)init
{
    self = [super init];
    
    if (self) {
        [self setupManagedObjectContext];
    }
    
    return self;
}

- (void)setupManagedObjectContext
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *documentDirectoryURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    
    NSURL *persistentURL = [documentDirectoryURL URLByAppendingPathComponent:@"ShopLater.sqlite"];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ShopLater" withExtension:@"momd"];
    
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError *error = nil;
    NSPersistentStore *persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                       configuration:nil
                                                                                                 URL:persistentURL
                                                                                             options:nil
                                                                                               error:&error];
    if (persistentStore) {
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    } else {
        NSLog(@"ERROR: %@", error.description);
    }
}

- (void)saveDataInManagedContextUsingBlock:(void (^)(BOOL saved, NSError *error))savedBlock
{
    NSError *saveError = nil;
    savedBlock([self.managedObjectContext save:&saveError], saveError);
}

- (NSFetchedResultsController *)fetchManagedObjectsWithClassName:(NSString *)className
                                             withSortDescriptors:(NSArray *)sortDescriptors
{
    NSFetchedResultsController *fetchedResultsController;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:className
                                              inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.sortDescriptors = sortDescriptors;
    
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    
    NSError *error = nil;
    BOOL success = [fetchedResultsController performFetch:&error];
    
    if (!success) {
        NSLog(@"fetchManagedObjectsWithClassName ERROR: %@", error.description);
    }
    
    return fetchedResultsController;
}

- (id)createEntityWithClassName:(NSString *)className atributesDictionary:(NSDictionary *)attributesDictionary
{
    id entity = [NSEntityDescription insertNewObjectForEntityForName:className
                                               inManagedObjectContext:self.managedObjectContext];
    [attributesDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];
        NSString *selectorName = [NSString stringWithFormat:@"set%@:", key];
        
        [entity performSelector:NSSelectorFromString(selectorName) withObject:obj];
    }];
    
    return entity;
}

@end
