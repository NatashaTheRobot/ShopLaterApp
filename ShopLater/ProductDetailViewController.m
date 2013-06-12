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
#import "WebViewController.h"

@interface ProductDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;

@property (strong, nonatomic) CoreDataManager *coreDataManager;

- (void)displayProductDetails;
- (void)showAlertView;

@end

@implementation ProductDetailViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.coreDataManager = [CoreDataManager sharedManager];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self displayProductDetails];

}

- (void)displayProductDetails
{
    self.productNameLabel.text = self.product.name;
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
    } else if ([segue.destinationViewController isKindOfClass:[WebViewController class]]) {
        WebViewController *webViewController = (WebViewController *)segue.destinationViewController;
        webViewController.product = self.product;
        webViewController.provider = self.product.provider;
    }
}

#pragma mark - Product Detail Delegate Methods
- (void)reloadProductDetails
{
    [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
        if (saved) {
            [self displayProductDetails];
            [self.delegate reloadProductData];
        } else {
            [self showAlertView];
        }
    }];
}

- (void)deleteProduct
{
    [self.coreDataManager deleteEntity:self.product];
    [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
        if (!error) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self.delegate reloadProductData];
        } else {
            [self showAlertView];
        }
    }];

    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"We're sorry, something went wrong :("
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
