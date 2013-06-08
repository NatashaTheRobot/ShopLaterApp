//
//  WelcomeViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ViewController.h"
#import "WelcomeViewControllerDelegate.h"

@interface WelcomeViewController : UIViewController

@property (strong, nonatomic) id<WelcomeViewControllerDelegate>delegate;

@end
