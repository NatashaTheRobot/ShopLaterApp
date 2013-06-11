//
//  CreateProductViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Provider.h"
#import "ProductDelegate.h"

@interface NewProductViewController : UIViewController

@property (strong, nonatomic) NSString *productURLString;
@property (strong, nonatomic) Provider *provider;
@property (strong, nonatomic) id<ProductDelegate> delegate;

@end
