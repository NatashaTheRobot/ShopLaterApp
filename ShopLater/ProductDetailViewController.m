//
//  ProductDetailViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "Constants.h"
#import "EditProductViewController.h"
#import "CoreDataManager.h"

@interface ProductDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextView *productNameTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;

- (void)displayProductDetails;

@end

@implementation ProductDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self displayProductDetails];
}

- (void)displayProductDetails
{
    self.productNameTextView.text = self.product.name;
    self.imageView.image = [self.product image];
    self.currentPriceLabel.text = [self.product formattedPriceWithType:sPriceTypeCurrent];
    self.wishPriceLabel.text = [self.product formattedPriceWithType:sPriceTypeWish];
    self.summaryTextView.text = self.product.summary;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[EditProductViewController class]]) {
        EditProductViewController *editViewController = (EditProductViewController *)segue.destinationViewController;
        editViewController.product = self.product;
        editViewController.delegate = self;
    }
}

- (void)reloadProductDetailData
{
    
}

- (void)deleteProduct
{
    CoreDataManager *coreDataManager = [CoreDataManager sharedManager];
    [coreDataManager deleteEntity:self.product];
    [coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
        if (!error) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self.delegate reloadProductData];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"We're sorry, something went wrong :("
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
            
            [alertView show];
        }
    }];

    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
