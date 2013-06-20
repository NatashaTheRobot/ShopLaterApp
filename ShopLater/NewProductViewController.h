//
//  CreateProductViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "Provider.h"

@interface NewProductViewController : GAITrackedViewController

@property (strong, nonatomic) NSString *productURLString;
@property (strong, nonatomic) Provider *provider;

@end
