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

- (BOOL)saveDataInManagedContext
{
    NSError *saveError = nil;
    BOOL didSave = [self.managedObjectContext save:&saveError];
    return didSave;
}

#pragma mark - Products

- (BOOL)productsExist
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([Product class])
                                      inManagedObjectContext:self.managedObjectContext];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"url" ascending:YES]];
    fetchRequest.fetchLimit = 1;
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:self.managedObjectContext
                                                            sectionNameKeyPath:nil
                                                            cacheName:nil];
    NSError *fetchError = nil;
    BOOL success = [fetchedResultsController performFetch:&fetchError];
    
    if (success) {
        
        if (fetchedResultsController.fetchedObjects.count > 0) {
            return YES;
        }
        
    } else {
        NSLog(@"Products Exists ERROR: %@", fetchError.description);
    }
    
    return NO;
}

#pragma mark - Providers

- (BOOL)providersExist
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([Provider class])
                                      inManagedObjectContext:self.managedObjectContext];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    fetchRequest.fetchLimit = 1;
   
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:fetchRequest
                                                            managedObjectContext:self.managedObjectContext
                                                            sectionNameKeyPath:nil
                                                            cacheName:nil];
    NSError *fetchError = nil;
    BOOL success = [fetchedResultsController performFetch:&fetchError];
    
    if (success) {
        
        if (fetchedResultsController.fetchedObjects.count > 0) {
            return YES;
        }
        
    } else {
        NSLog(@"Providers Exists ERROR: %@", fetchError.description);
    }
    
    return NO;
}

- (void)createProviderWithName:(NSString *)name
{
    Provider *provider = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Provider class])
                                                       inManagedObjectContext:self.managedObjectContext];
    provider.name = name;
    provider.url = [NSString stringWithFormat:@"http://www.%@.com", name];
    
    Image *image = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Image class])
                                                 inManagedObjectContext:self.managedObjectContext];
    image.fileName = [NSString stringWithFormat:@"%@_logo.png", name];
    image.provider = provider;
}

@end
