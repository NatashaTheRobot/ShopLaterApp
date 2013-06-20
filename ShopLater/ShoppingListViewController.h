//
//  ShoppingListViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/17/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDelegate.h"

@interface ShoppingListViewController : UICollectionViewController <ProductDelegate>

- (void)revealMenu:(id)sender;

@end
