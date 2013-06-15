//
//  ProductsListViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProductsListViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "CoreDataManager.h"
#import "ProviderViewController.h"
#import "Product+SLExtensions.h"
#import "Constants.h"
#import "ProductTableViewCell.h"
#import "Image+SLExtensions.h"
#import "Price+SLExtensions.h"
#import "Provider+SLExtensions.h"
#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"
#import "Parser.h"

@interface ProductsListViewController ()

@property (assign, nonatomic) BOOL productsExist;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)selectViewController;
- (void)addRefreshControl;
- (void)getUpdatedPrices;

- (IBAction)revealMenuWithButton:(id)sender;

@end

@implementation ProductsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.coreDataManager = [CoreDataManager sharedManager];
    
    [self addRefreshControl];
    
    [self selectViewController];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.8f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.cornerRadius = 4;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:
                                                               NSStringFromClass([MenuViewController class])];
    }
    
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
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
            NSNumber *newPrice = [parser.delegate priceInDollars];
            if ([currentPrice.dollarAmount floatValue] != [newPrice floatValue]) {
                NSIndexPath *productIndexPath = [self.fetchedResultsController indexPathForObject:product];
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentPrice.dollarAmount = newPrice;
                    [self.tableView reloadRowsAtIndexPaths:@[productIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
                [self.refreshControl endRefreshing];
            }];
        });
    });
}

- (IBAction)revealMenuWithButton:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
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
                                                                  sectionNameKeyPath:@"name"
                                                                           predicate:nil];

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
    } else if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
        Product *product = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        webViewController.product = product;
        webViewController.provider = product.provider;
    }
    [self.refreshControl endRefreshing];
}


- (void)reloadProductData
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Product class])
                                                                     sortDescriptors:sortDescriptors
                                                                  sectionNameKeyPath:@"name"
                                                                           predicate:nil];
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
    
//    if ([product.priceDifference floatValue] <= 0) {
//        cell.layer.borderColor = [[UIColor redColor] CGColor];
//        cell.layer.borderWidth = 1.0f;
//    }
    
    return cell;
}

@end
