//
//  ProviderViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProviderViewController.h"
#import "CoreDataManager.h"
#import "Provider+SLExtensions.h"
#import "Image+SLExtensions.h"
#import "ProviderCollectionViewCell.h"
#import "WebViewController.h"
#import "Constants.h"

@interface ProviderViewController ()

@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)createProviders;
- (void)fetchProviders;

@end

@implementation ProviderViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.coreDataManager = [CoreDataManager sharedManager];
        self.managedObjectContext = self.coreDataManager.managedObjectContext;
        
        [self fetchProviders];
        
        if (self.fetchedResultsController.fetchedObjects.count == 0) {
            [self createProviders];
        }
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.showNavigationBar) {
        self.navigationItem.hidesBackButton = YES;
    }
	
}

#pragma mark - Setup

- (void)createProviders
{
    NSArray *providers = [Provider providersArray];
    
    [providers enumerateObjectsUsingBlock:^(NSDictionary *providerDictionary, NSUInteger idx, BOOL *stop) {
        [self.coreDataManager createEntityWithClassName:NSStringFromClass([Provider class]) atributesDictionary:providerDictionary];
    }];
    
    [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
        if (saved) {
            [self fetchProviders];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"We're sorry, something went wrong :("
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
            
            [alertView show];
        }
    }];
}

- (void)fetchProviders
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    self.fetchedResultsController = [self.coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Provider class])
                                                                       withSortDescriptors:sortDescriptors];
}

#pragma mark - CollectionView Delegate Methods

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
    ProviderCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:sProviderCellIdentifier forIndexPath:indexPath];
    
    Provider *provider = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.image = [Image imageForProvider:provider type:sImageTypeLogo];
    
    return cell;
}

#pragma mark - AlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedIndexPath = [self.collectionView indexPathsForSelectedItems][0];
    Provider *provider = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
    
    ((WebViewController *)segue.destinationViewController).provider = provider;
}


@end
