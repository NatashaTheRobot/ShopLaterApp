//
//  WebViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "Provider.h"
#import "Product.h"

@interface WebViewController : GAITrackedViewController

@property (strong, nonatomic) Provider *provider;
@property (strong, nonatomic) Product *product;

@property (assign, nonatomic) BOOL fromMenu;

- (void)revealMenu:(id)sender;

@end
