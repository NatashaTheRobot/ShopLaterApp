//
//  WelcomeViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

- (IBAction)addItemWithButton:(id)sender;

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)addItemWithButton:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate addItemAction];
    }];
}
@end
