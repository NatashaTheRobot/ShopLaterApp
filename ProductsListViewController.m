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
#import <QuartzCore/QuartzCore.h>
#import "ProductDetailViewController.h"
#import "Parser.h"

@interface ProductsListViewController ()

@property (assign, nonatomic) BOOL productsExist;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)selectViewController;
- (void)addRefreshControl;
- (void)getUpdatedPrices;

@end

@implementation ProductsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.coreDataManager = [CoreDataManager sharedManager];
    
    [self addRefreshControl];
    
    [self selectViewController];

}

- (void)addRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getUpdatedPrices) forControlEvents:UIControlEventValueChanged];
}

- (void)getUpdatedPrices
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(Product *product, NSUInteger idx, BOOL *stop) {
            Parser *parser = [Parser parserWithProviderName:product.provider.name productURLString:product.mobileURL];
            Price *currentPrice = [product priceWithType:sPriceTypeCurrent];
            currentPrice.dollarAmount = [parser.delegate priceInDollars];
        }];
        [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
            if (saved) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing];
                    [self reloadProductData];
                });
            } else {
                [self.refreshControl endRefreshing];
            }
        }];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self performSegueWithIdentifier:@"toProviderCollectionView" sender:self];
    }
}

- (void)selectViewController
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sProductSortAttribute ascending:YES]];
    
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Product class])
                                                                     sortDescriptors:sortDescriptors
                                                                  sectionNameKeyPath:nil];

    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self performSegueWithIdentifier:@"toProviderCollectionView" sender:self];
    } else {
        [self.refreshControl beginRefreshing];
        [self getUpdatedPrices];
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
        productDetailViewController.delegate = self;
    }
}


- (void)reloadProductData
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sProductSortAttribute ascending:YES]];
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Product class])
                                                                     sortDescriptors:sortDescriptors
                                                                  sectionNameKeyPath:nil];
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
        cell = [[ProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sProductCellIdentifier];
    }
    
    Product *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.productName = product.name;
    cell.productImage = [product image];
    cell.currentPrice = [product formattedPriceWithType:sPriceTypeCurrent];
    cell.wishPrice = [product formattedPriceWithType:sPriceTypeWish];
    cell.provider = product.provider;
    
    if ([product.priceDifference floatValue] <= 0) {
        cell.layer.borderColor = [[UIColor redColor] CGColor];
        cell.layer.borderWidth = 1.0f;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
