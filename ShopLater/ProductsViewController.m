//
//  ProductsViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProductsViewController.h"
#import "CoreDataManager.h"
#import "WelcomeViewController.h"

@interface ProductsViewController ()

@end

@implementation ProductsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self selectViewController];
    
}

- (void)selectViewController
{
    CoreDataManager *coreDataManager = [CoreDataManager sharedManager];
    
    if (![coreDataManager productsExist]) {
        [self performSegueWithIdentifier:@"welcome" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[WelcomeViewController class]]) {
        WelcomeViewController *welcomeViewController = segue.destinationViewController;
        welcomeViewController.delegate = self;
    }
}

- (void)addItemAction
{
    [self performSegueWithIdentifier:@"toProviderCollectionView" sender:self];
}

@end
