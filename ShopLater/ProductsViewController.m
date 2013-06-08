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

@interface ProductsViewController ()

@property (assign, nonatomic) BOOL productsExist;

@end

@implementation ProductsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self selectViewController];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.productsExist) {
        [self performSegueWithIdentifier:@"toProviderCollectionView" sender:self];
    }
}

- (void)selectViewController
{
    CoreDataManager *coreDataManager = [CoreDataManager sharedManager];
    
    self.productsExist = [coreDataManager productsExist];
    if (!self.productsExist) {
        [self performSegueWithIdentifier:@"toProviderCollectionView" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (self.productsExist) {
        ((ProviderViewController *)segue.destinationViewController).showNavigationBar = YES;
    } else {
        ((ProviderViewController *)segue.destinationViewController).showNavigationBar = NO;
    }
}

@end
