//
//  ViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataManager.h"
#import "WelcomeViewController.h"

@interface ViewController ()

- (void)selectViewController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self selectViewController];
    
}

- (void)selectViewController
{
    CoreDataManager *coreDataManager = [CoreDataManager sharedManager];
    
    if (![coreDataManager productsExist]) {
        
        ((WelcomeViewController *)self.childViewControllers[0]).delegate = self;
        
        [self transitionFromViewController:self.childViewControllers[1]
                          toViewController:self.childViewControllers[0]
                                  duration:0
                                   options:0
                                animations:nil
                                completion:^(BOOL finished) {
                                    
                                }];
    }
}

#pragma mark - welcome delegate

- (void)addItemAction
{
    [self performSegueWithIdentifier:@"toProviderCollectionView" sender:self];
}

@end
