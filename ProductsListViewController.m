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
#import "Product+SLExtensions.h"
#import "Constants.h"
#import "ProductTableViewCell.h"
#import "Image+SLExtensions.h"
#import "Price+SLExtensions.h"
#import "Provider+SLExtensions.h"
#import "SectionHeaderCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ProductDetailViewController.h"

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
    
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Product class])
                                                                     sortDescriptors:sortDescriptors
                                                                  sectionNameKeyPath:@"provider.name"];

    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self performSegueWithIdentifier:@"toProviderCollectionView" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ProviderViewController class]]) {
        ((ProviderViewController *)segue.destinationViewController).showNavigationBar = (self.fetchedResultsController.fetchedObjects.count == 0);
    } else if ([segue.destinationViewController isKindOfClass:[ProductDetailViewController class]]) {
        Product *product = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        
        ProductDetailViewController *productDetailViewController = (ProductDetailViewController *)segue.destinationViewController;
        productDetailViewController.product = product;
    }
}


- (void)reloadProductData
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Product class])
                                                                     sortDescriptors:sortDescriptors
                                                                  sectionNameKeyPath:@"provider.name"];
    [self.tableView reloadData];
    
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
    ProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sProductCellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[ProductTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sProductCellIdentifier];
    }
    
    Product *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.productName = product.name;
    cell.productImage = [product image];
    cell.currentPrice = [product formattedPriceWithType:sPriceTypeCurrent];
    cell.wishPrice = [product formattedPriceWithType:sPriceTypeWish];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SectionHeaderCell *headerCell = [tableView dequeueReusableCellWithIdentifier:sProviderCellIdentifier];
    
    if (!headerCell) {
        headerCell = [[SectionHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sProviderCellIdentifier];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    headerCell.providerLogo = [UIImage imageNamed:[Provider sectionImageNameFromProviderName:sectionInfo.name]];
    
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

@end
