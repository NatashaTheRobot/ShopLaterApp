//
//  ProductsViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProductsViewController.h"
#import "CoreDataManager.h"
#import "ProviderViewController.h"
#import "Product.h"

@interface ProductsViewController ()

@property (assign, nonatomic) BOOL productsExist;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ProductsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.coreDataManager = [CoreDataManager sharedManager];
    
    [self selectViewController];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self performSegueWithIdentifier:@"toProviderCollectionView" sender:self];
    }
}

- (void)selectViewController
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    self.fetchedResultsController = [self.coreDataManager
                                     fetchEntitiesWithClassName:NSStringFromClass([Product class])
                                     withSortDescriptors:sortDescriptors];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self performSegueWithIdentifier:@"toProviderCollectionView" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        ((ProviderViewController *)segue.destinationViewController).showNavigationBar = YES;
    } else {
        ((ProviderViewController *)segue.destinationViewController).showNavigationBar = NO;
    }
}

@end
