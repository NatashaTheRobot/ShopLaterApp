//
//  CreateProductViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "NewProductViewController.h"
#import "Parser.h"
#import "Price+SLExtensions.h"
#import "Product.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "ProductsListViewController.h"
#import "Constants.h"

@interface NewProductViewController ()


@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *priceSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) Parser *parser;
@property (strong, nonatomic) Product *product;

- (IBAction)adjustWishPrice:(id)sender;
- (IBAction)saveProductWithButton:(id)sender;

- (void)displayProduct;
- (void)createProduct;

@end

@implementation NewProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self displayProduct];
        [self createProduct];
    });
    
}

- (void)displayProduct
{
    self.parser = [Parser parserWithProviderName:self.provider.name productURLString:self.productURLString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *priceInDollars = [(Price *)[self.parser.delegate productPrice] dollarAmount];
        self.productNameLabel.text = [self.parser.delegate productName];
        self.currentPriceLabel.text = [NSString stringWithFormat:@"$%@", priceInDollars];
        self.priceSlider.maximumValue = [priceInDollars floatValue];
        self.priceSlider.value = [priceInDollars floatValue] * 0.8;
        self.wishPriceLabel.text = [NSString stringWithFormat:@"$%.2f", ([priceInDollars floatValue] * 0.8)];
        [self.view viewWithTag:1].alpha = 0;
        
        Image *image = [self.parser.delegate productImage];
        [image downloadImageFromURL:[NSURL URLWithString:image.externalURLString] completionBlock:^(BOOL succeeded, UIImage *image) {
            self.imageView.image = image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.activityIndicator stopAnimating];
        }];
    });
    
}

- (void)createProduct
{
    NSSet *images = [NSSet setWithObject:[self.parser.delegate productImage]];
    NSSet *prices = [NSSet setWithObject:[self.parser.delegate productPrice]];
    
    NSDictionary *productDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[self.parser.delegate productName], @"name",
                                       [self.parser.delegate productSummary], @"summary",
                                       self.productURLString, @"url",
                                       images, @"images",
                                       prices, @"prices",
                                       self.provider, @"provider",
                                       [self.parser.delegate mobileURLString], @"mobileURL",
                                       nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.coreDataManager = [CoreDataManager sharedManager];
        self.product = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Product class])
                                                              atributesDictionary:productDictionary];
    });
    
}

- (IBAction)adjustWishPrice:(UISlider *)slider
{
    self.wishPriceLabel.text = [NSString stringWithFormat:@"$%.2f", slider.value];
}

- (IBAction)saveProductWithButton:(id)sender
{
    NSDictionary *wishPriceDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithFloat:self.priceSlider.value], @"dollarAmount",
                                         sPriceTypeWish, @"type",
                                         [NSDate date], @"created_at",
                                         nil];
    Price *wishPrice = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Price class])
                                                   atributesDictionary:wishPriceDictionary];
    self.product.prices = [self.product.prices setByAddingObject:wishPrice];
    
    [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
        if (saved) {
            self.delegate = (ProductsListViewController *)self.navigationController.viewControllers[0];
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self.delegate reloadProductData];
        } else {
            NSLog(@"%@", error.description);
            // show alert view?
        }
    }];
    
}
@end
