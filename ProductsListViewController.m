//
//  ProductsListViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProductsListViewController.h"
#import "CoreDataManager.h"
#import "ProviderViewController.h"
#import "Product.h"
#import "Constants.h"
#import "ProductTableViewCell.h"
#import "Image+SLExtensions.h"

@interface ProductsListViewController ()

@property (assign, nonatomic) BOOL productsExist;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)selectViewController;

@end

@implementation ProductsListViewController

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

- (void)reloadData
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Product class]) withSortDescriptors:sortDescriptors];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sProductCellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[ProductTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sProductCellIdentifier];
    }
    
    Product *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = product.name;
    cell.imageView.image = [(Image *)[product.images anyObject] image];
    
    return cell;
}

@end
