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
#import "Product+SLExtensions.h"
#import "Constants.h"
#import "ProductTableViewCell.h"
#import "Image+SLExtensions.h"
#import "Price+SLExtensions.h"
#import "Provider+SLExtensions.h"
#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"
#import "WelcomView.h"

@interface ProductsListViewController () <NSFetchedResultsControllerDelegate>

@property (assign, nonatomic) BOOL productsExist;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)addRefreshControl;
- (void)getUpdatedProductData;
- (void)fetchProducts;

- (IBAction)revealMenuWithButton:(id)sender;

- (void)configureCell:(ProductTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ProductsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.coreDataManager = [CoreDataManager sharedManager];
    
    [self addRefreshControl];
    
    [self fetchProducts];
}

- (void)fetchProducts
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sProductSortAttribute ascending:NO]];
    
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Product class])
                                                                     sortDescriptors:sortDescriptors
                                                                  sectionNameKeyPath:@"name"
                                                                           predicate:nil];
    self.fetchedResultsController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.8f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:
                                                               NSStringFromClass([MenuViewController class])];
    }
    
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        WelcomView *welcomeView = [[WelcomView alloc] initWithFrame:CGRectMake(10, 50, self.view.frame.size.width - 40, 200)];
        [self.view addSubview:welcomeView];
        
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
}

- (void)addRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getUpdatedProductData) forControlEvents:UIControlEventValueChanged];
}

- (void)getUpdatedProductData
{
    [self.refreshControl endRefreshing];
}

- (IBAction)revealMenuWithButton:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
        Product *product = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        webViewController.product = product;
        webViewController.provider = product.provider;
    }
    [self.refreshControl endRefreshing];
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
    
    cell.product = product;
    
//    if ([product.priceDifference floatValue] <= 0) {
//        cell.layer.borderColor = [[UIColor redColor] CGColor];
//        cell.layer.borderWidth = 1.0f;
//    }
    cell.delegate = self;
    
    return cell;
}

#pragma mark - NSFetchResultsController Delegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(ProductTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.product = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(ProductTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

#pragma mark - Product Delegate Methods

- (void)deleteProduct:(Product *)product
{
    [self.coreDataManager deleteEntity:product];
    [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"We're sorry, but this product could not be deleted. Please try again"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

@end
