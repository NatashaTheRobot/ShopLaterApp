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

- (IBAction)saveProductWithButton:(id)sender;
@end

@implementation NewProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayProduct];
    });
    
}



// asynchronous!
- (void)displayProduct
{
    Parser *parser = [Parser parserWithProviderName:self.provider.name productURLString:self.productURLString];
    
    self.productTitleTextView.text = [parser.delegate productName];
    self.currentPriceLabel.text = [NSString stringWithFormat:@"$%@", [(Price *)[parser.delegate productPrice] dollarAmount]];
    
    Image *image = [parser.delegate productImage];
    [image downloadImageFromURL:[NSURL URLWithString:image.externalURLString] completionBlock:^(BOOL succeeded, UIImage *image) {
        self.imageView.image = image;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }];
    
    
}

- (IBAction)saveProductWithButton:(id)sender
{
    // use delegate so the products view controller reloads table view data
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
