//
//  CreateProductViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "CreateProductViewController.h"

@interface CreateProductViewController ()

@property (weak, nonatomic) IBOutlet UITextView *productTitleTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *priceSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;

- (IBAction)saveProductWithButton:(id)sender;
@end

@implementation CreateProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)saveProductWithButton:(id)sender
{
    // use delegate so the products view controller reloads table view data
    [self.parentViewController.navigationController popToRootViewControllerAnimated:YES];
}
@end
