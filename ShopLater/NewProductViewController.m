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
#import "Product+SLExtensions.h"
#import "Image+SLExtensions.h"
#import "CoreDataManager.h"
#import "ProductsListViewController.h"
#import "Constants.h"
#import "ECSlidingViewController.h"

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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayProduct];
        [self createProduct];
    });
    
    [self.slidingViewController setAnchorRightRevealAmount:280.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
}

- (void)displayProduct
{
    self.parser = [Parser parserWithProviderName:self.provider.name productURLString:self.productURLString];
    
    NSNumber *priceInDollars = [(Price *)[self.parser.delegate productPrice] dollarAmount];
    self.productNameLabel.text = [self.parser.delegate productName];
    self.currentPriceLabel.text = [NSString stringWithFormat:@"$%.2f", [priceInDollars floatValue]];
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
}

- (void)createProduct
{    
    NSDictionary *productDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[self.parser.delegate productName], @"name",
                                       [self.parser.delegate cleanURLString], @"url",
                                       self.provider, @"provider",
                                       [self.parser.delegate mobileURLString], @"mobileURL",
                                       [NSDate date], @"createdAt",
                                       nil];
    self.coreDataManager = [CoreDataManager sharedManager];
    
    self.product = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Product class])
                                              attributesDictionary:productDictionary];
    
    [self.product addImagesObject:[self.parser.delegate productImage]];
    [self.product addPricesObject:[self.parser.delegate productPrice]];
    
    
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
                                                   attributesDictionary:wishPriceDictionary];
    self.product.prices = [self.product.prices setByAddingObject:wishPrice];
    self.product.priceDifference = [self.product currentWishPriceDifference];
    
    [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
        if (saved) {
            UINavigationController *productListNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"first"];
            
            [self.slidingViewController resetTopViewWithAnimations:nil onComplete:^{
                CGRect frame = self.slidingViewController.topViewController.view.frame;
                self.slidingViewController.topViewController = productListNavigationController;
                self.slidingViewController.topViewController.view.frame = frame;
                [self.slidingViewController resetTopView];

            }];
        } else {
            NSLog(@"%@", error.description);
            // show alert view?
        }
    }];
    
}
@end
