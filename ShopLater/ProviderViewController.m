//
//  ProviderViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProviderViewController.h"
#import "CoreDataManager.h"
#import "Provider.h"
#import "Image.h"
#import "ProviderCollectionViewCell.h"
#import "WebViewController.h"

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
        
        if (![self.coreDataManager providersExist]) {
            [self createProviders];
        }
        [self fetchProviders];
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

- (void)viewDidAppear:(BOOL)animated
{
    if (![self.coreDataManager providersExist]) {
        [self createProviders];
        [self fetchProviders];
        [self.collectionView reloadData];
    }
}

#pragma mark - Setup

- (void)createProviders
{
    NSMutableArray *providers = [[NSMutableArray alloc] initWithCapacity:1];
    
    // provider dictionaries
    NSDictionary *toysrusDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"toysrus", @"name",
                                                                                 @"productId", @"identifierName",
                                       nil];
    
    [providers addObject:toysrusDictionary];
    
    [providers enumerateObjectsUsingBlock:^(NSDictionary *providerDictionary, NSUInteger idx, BOOL *stop) {
        [self.coreDataManager createProviderWithDictionary:providerDictionary];
    }];
    
    BOOL didSave = [self.coreDataManager saveDataInManagedContext];
    if (!didSave) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"We're sorry, something went wrong :("
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }
}

- (void)fetchProviders
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Provider class])
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    
    NSError *error = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    
    if (!success) {
        NSLog(@"fetchProviders ERROR: %@", error.description);
    }
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
    static NSString *cellIdentifier = @"provider";
    
    ProviderCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Provider *provider = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *logoImageName = ((Image *)[provider.images anyObject]).fileName;
    
    cell.image = [UIImage imageNamed:logoImageName];
    
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
