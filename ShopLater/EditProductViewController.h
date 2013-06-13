//
//  EditProductViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product+SLExtensions.h"
#import "ProductDetailDelegate.h"
#import "EditViewController.h"
#import "EditDelegate.h"

@interface EditProductViewController : UIViewController <UITextViewDelegate, EditDelegate>

@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) id<ProductDetailDelegate> delegate;

-(void)updateTextViewInDetailViewController:(NSString *)withString;


@end
