//
//  ShoppingListViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/17/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ShoppingListViewController.h"
#import "ProductCollectionViewCell.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "CoreDataManager.h"
#import "Product+SLExtensions.h"
#import "Constants.h"
#import "Provider+SLExtensions.h"
#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"
#import "WelcomeView.h"
#import "ButtonFactory.h"

@interface ShoppingListViewController () <NSFetchedResultsControllerDelegate>

@property (assign, nonatomic) BOOL productsExist;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)customizeNavigationBar;
- (void)revealMenu;
- (void)fetchProducts;

- (void)configureCell:(ProductCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ShoppingListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customizeNavigationBar];
	
    self.coreDataManager = [CoreDataManager sharedManager];
    
    [self fetchProducts];
}

- (void)customizeNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"nav_bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];

    self.navigationItem.leftBarButtonItem = [ButtonFactory barButtonItemWithImageName:@"menu_btn.png"
                                                                               target:self
                                                                               action:@selector(revealMenu)];
}

- (void)fetchProducts
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sProductSortAttribute ascending:NO]];
    
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Product class])
                                                                     sortDescriptors:sortDescriptors
                                                                  sectionNameKeyPath:nil
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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    ((MenuViewController *)self.slidingViewController.underLeftViewController).selectedProvider = nil;
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        WelcomeView *welcomeView = [[WelcomeView alloc] initWithFrame:CGRectMake(10, 50, self.view.frame.size.width - 40, 200)];
        [self.view addSubview:welcomeView];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideMenu) name:ECSlidingViewTopDidReset object:nil];

    }
}

- (void)slideMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight animations:nil onComplete:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECSlidingViewTopDidReset object:nil];
    }];
    
}

- (void)revealMenu
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
        Product *product = [self.fetchedResultsController objectAtIndexPath:[self.collectionView indexPathsForSelectedItems][0]];
        
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        webViewController.product = product;
        webViewController.provider = product.provider;
    }
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:sProductCellIdentifier forIndexPath:indexPath];
    
    Product *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.product = product;
    
    cell.delegate = self;
    
    return cell;

}

#pragma mark - NSFetchResultsController Delegate Methods

- (void)configureCell:(ProductCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
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
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(ProductCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
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
