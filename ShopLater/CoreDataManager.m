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

- (Product *)createProductWithDictionary:(NSDictionary *)productDictionary
{
    Product *product = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Product class])
                                                     inManagedObjectContext:self.managedObjectContext];
    product.name = productDictionary[@"name"];
    product.url = productDictionary[@"url"];
    
    if (productDictionary[@"summary"]) {
        product.summary = productDictionary[@"summary"];
    }
    
    if (productDictionary[@"externalId"]) {
        product.externalId = productDictionary[@"externalId"];
    }
    
    product.prices = [NSSet setWithObject:productDictionary[@"price"]];
    product.images = [NSSet setWithObject:productDictionary[@"image"]];
    
    return product;
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

- (Provider *)createProviderWithDictionary:(NSDictionary *)providerDictionary
{
    Provider *provider = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Provider class])
                                                       inManagedObjectContext:self.managedObjectContext];
    provider.name = providerDictionary[@"name"];
    provider.url = [NSString stringWithFormat:@"http://www.%@.com", provider.name];
    provider.identifierName = providerDictionary[@"identifierName"];
    
    NSString *imageLogoName = [NSString stringWithFormat:@"%@_logo.png", provider.name];
    NSDictionary *logoImageDictionary = [NSDictionary dictionaryWithObjectsAndKeys: imageLogoName, @"fileName",
                                                                                     provider, @"provider", nil];
    
    [self createImageWithDictionary:logoImageDictionary];
    
    NSString *exampleImageName = [NSString stringWithFormat:@"%@_example.png", provider.name];
    
    NSDictionary *exampleImageDictionary = [NSDictionary dictionaryWithObjectsAndKeys: exampleImageName, @"fileName",
                                                                                       provider, @"provider", nil];
    
    [self createImageWithDictionary:exampleImageDictionary];
    
    return provider;

}

# pragma mark - Images

- (Image *)createImageWithDictionary:(NSDictionary *)imageDictionary
{
    Image *image = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Image class])
                                                     inManagedObjectContext:self.managedObjectContext];
    image.fileName = imageDictionary[@"fileName"];
    
    if (imageDictionary[@"provider"]) {
        image.provider = imageDictionary[@"provider"];
    }
    if (imageDictionary[@"product"]) {
        image.product = imageDictionary[@"product"];
    }
    
    return image;
}

# pragma mark - Prices

- (Price *)createPriceWithDictionary:(NSDictionary *)priceDictionary
{
    Price *price = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Price class])
                                                 inManagedObjectContext:self.managedObjectContext];
    
    price.dollarAmount = priceDictionary[@"dollarAmount"];
    
    if (priceDictionary[@"type"]) {
        price.type = priceDictionary[@"type"];
    } else {
        price.type = @"current";
    }
    
    price.created_at = [NSDate date];
    
    if (priceDictionary[@"product"]) {
        price.product = priceDictionary[@"product"];
    }
    
    return price;
}

@end
