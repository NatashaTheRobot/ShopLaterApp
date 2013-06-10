//
//  CreateProductViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "NewProductViewController.h"
#import "Parser.h"
#import "Price.h"
#import "Image+SLExtensions.h"

@interface NewProductViewController ()

@property (weak, nonatomic) IBOutlet UITextView *productTitleTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *priceSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)adjustWishPrice:(id)sender;

- (IBAction)saveProductWithButton:(id)sender;
@end

@implementation NewProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self displayProduct];
    });
    
}

- (void)displayProduct
{
    Parser *parser = [Parser parserWithProviderName:self.provider.name productURLString:self.productURLString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *priceInDollars = [(Price *)[parser.delegate productPrice] dollarAmount];
        self.productTitleTextView.text = [parser.delegate productName];
        self.currentPriceLabel.text = [NSString stringWithFormat:@"$%@", priceInDollars];
        self.priceSlider.maximumValue = [priceInDollars floatValue];
        self.priceSlider.value = [priceInDollars floatValue] * 0.8;
        self.wishPriceLabel.text = [NSString stringWithFormat:@"$%.2f", ([priceInDollars floatValue] * 0.8)];
        self.priceSlider.hidden = NO;
        
        Image *image = [parser.delegate productImage];
        [image downloadImageFromURL:[NSURL URLWithString:image.externalURLString] completionBlock:^(BOOL succeeded, UIImage *image) {
            self.imageView.image = image;
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.activityIndicator stopAnimating];
        }];
    });
    
}

- (IBAction)adjustWishPrice:(UISlider *)slider
{
    self.wishPriceLabel.text = [NSString stringWithFormat:@"$%.2f", slider.value];
}

- (IBAction)saveProductWithButton:(id)sender
{
    // use delegate so the products view controller reloads table view data
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
