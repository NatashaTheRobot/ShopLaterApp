//
//  EditProductViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/11/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "EditProductViewController.h"
#import "Constants.h"
#import "Price+SLExtensions.h"

@interface EditProductViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;
@property (weak, nonatomic) IBOutlet UISlider *priceSlider;

- (IBAction)saveWithButton:(id)sender;
- (IBAction)cancelWithButton:(id)sender;
- (IBAction)adjustPrice:(id)sender;
- (IBAction)deleteWithButton:(id)sender;

- (void)setupEditFields;

@end

@implementation EditProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupEditFields];
}

- (void)setupEditFields
{
    self.imageView.image = [self.product image];
    self.titleTextField.placeholder = self.product.name;
    self.wishPriceLabel.text = [self.product formattedPriceWithType:sPriceTypeWish];
    self.summaryTextView.text = self.product.summary;
    self.priceSlider.maximumValue = [[self.product priceWithType:sPriceTypeCurrent].dollarAmount floatValue];
    self.priceSlider.value = [[self.product priceWithType:sPriceTypeWish].dollarAmount floatValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveWithButton:(id)sender
{
    
}

- (IBAction)cancelWithButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)adjustPrice:(id)sender
{
    self.wishPriceLabel.text = [NSString stringWithFormat:@"$%.2f", self.priceSlider.value];
}

- (IBAction)deleteWithButton:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate deleteProduct];
    }];
        
}
@end
