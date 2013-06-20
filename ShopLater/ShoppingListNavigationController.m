//
//  ShoppingListNavigationViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/20/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ShoppingListNavigationController.h"
#import "Constants.h"
#import "ButtonFactory.h"
#import "MenuViewController.h"
#import "ECSlidingViewController.h"

@interface ShoppingListNavigationController ()

@end

@implementation ShoppingListNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    }
    
    self.view.layer.shadowOpacity = 0.8f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1] CGColor];
    
    [self.slidingViewController setAnchorRightRevealAmount:sMenuAnchorRevealAmount];
    self.slidingViewController.shouldAllowUserInteractionsWhenAnchored = YES;
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    [self.navigationBar setBackgroundImage:[UIImage imageNamed: @"nav_bar.png"]
                             forBarMetrics:UIBarMetricsDefault];
}

@end
