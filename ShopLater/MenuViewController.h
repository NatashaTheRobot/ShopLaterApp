//
//  MenuViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Provider+SLExtensions.h"

@interface MenuViewController : UITableViewController

@property (strong, nonatomic) Provider *selectedProvider;

@end
