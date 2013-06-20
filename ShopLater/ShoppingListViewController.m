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
#import "WebViewController.h"
#import "ButtonFactory.h"

@interface ShoppingListViewController () <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) BOOL productsExist;
@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) Product *productToDelete;
@property (strong, nonatomic) Product *producttoBuy;

- (void)customizeNavigationBar;
- (void)fetchProducts;
- (void)showWelcomeView;

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
    self.navigationItem.leftBarButtonItem = [ButtonFactory barButtonItemWithImageName:@"menu_btn.png"
                                                                               target:self
                                                                               action:@selector(revealMenu:)];
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

- (void)viewDidAppear:(BOOL)animated
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self showWelcomeView];
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"LaunchTime"] == 0) {
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self revealMenu:self];
            });
            
        }
    }
    
}

- (void)showWelcomeView
{
    UIImage *welcomeImage = [UIImage imageNamed:@"welcome.png"];
    
    UIImageView *welcomeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - welcomeImage.size.width / 2, self.view.frame.size.height/ 2 - welcomeImage.size.height, welcomeImage.size.width, welcomeImage.size.height)];
    
    welcomeImageView.image = welcomeImage;
    
    [self.view addSubview:welcomeImageView];
}

- (void)revealMenu:(id)sender
{
    if (self.slidingViewController.underLeftShowing) {
        [self.slidingViewController resetTopView];
    } else {
        ((MenuViewController *)self.slidingViewController.underLeftViewController).selectedProvider = nil;
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
        
        Product *product;
        
        if (self.producttoBuy) {
            product = self.producttoBuy;
            self.producttoBuy = nil;
        } else {
            product = [self.fetchedResultsController objectAtIndexPath:[self.collectionView indexPathsForSelectedItems][0]];
        }
        
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
    
    [cell clearNameLabelView];
    
    cell.product = product;
    
    cell.delegate = self;
    
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Product *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *text = product.name;
    CGSize maximumLabelSize = CGSizeMake(250, CGFLOAT_MAX);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    CGSize expectedLabelSize = [text sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = expectedLabelSize.height + 350;
    return CGSizeMake(290, height);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [(ProductCollectionViewCell *)cell clearNameLabelView];
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
    self.productToDelete = product;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Are you sure you want to delete this item?"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
    alertView.delegate = self;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"YES"]) {
        [self.coreDataManager deleteEntity:self.productToDelete];
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
}

- (void)buyProduct:(Product *)product
{
    self.producttoBuy = product;
    [self performSegueWithIdentifier:@"toWebView" sender:self];
}


@end
