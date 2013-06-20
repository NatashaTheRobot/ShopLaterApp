//
//  WebViewNativationController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/20/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "WebViewNativationController.h"
#import "MenuViewController.h"
#import "ECSlidingViewController.h"

@interface WebViewNativationController ()

@end

@implementation WebViewNativationController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.layer.shadowOpacity = 0.8f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1] CGColor];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MenuViewController class])];
    }
    
    [self.navigationBar setBackgroundImage:[UIImage imageNamed: @"nav_bar.png"]
                             forBarMetrics:UIBarMetricsDefault];
    
}


@end
