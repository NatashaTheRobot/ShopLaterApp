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
@property (weak, nonatomic) IBOutlet UISlider *priceSlider;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UITextView *summaryTextView;

- (IBAction)saveWithButton:(id)sender;
- (IBAction)cancelWithButton:(id)sender;
- (IBAction)adjustPrice:(id)sender;

- (void)setupEditFields;
- (void)makeSummaryTextView;
- (void)makeDeleteButton;
- (void)deleteWithButton;

@end

@implementation EditProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self makeSummaryTextView];
	
    [self setupEditFields];
    
    [self makeDeleteButton];
}

- (void)setupEditFields
{
    self.imageView.image = [self.product image];
    self.titleTextField.placeholder = self.product.name;
    self.summaryTextView.text = self.product.summary;
    self.wishPriceLabel.text = [self.product formattedPriceWithType:sPriceTypeWish];
    self.priceSlider.maximumValue = [[self.product priceWithType:sPriceTypeCurrent].dollarAmount floatValue];
    self.priceSlider.value = [[self.product priceWithType:sPriceTypeWish].dollarAmount floatValue];
}

- (void)makeSummaryTextView
{
    
    CGSize size = [self.product.summary sizeWithFont:[UIFont systemFontOfSize:14]
                                   constrainedToSize:CGSizeMake(100, 2000)
                                       lineBreakMode:NSLineBreakByCharWrapping];
    
    self.summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.editButton.frame.origin.x, self.editButton.frame.origin.y + 50, self.view.frame.size.width - 100, size.height + 10)];
    
    CGSize scrollViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + self.summaryTextView.frame.size.height);
    
    UIFont *font = [UIFont fontWithName:@"Georgia" size:14.0];

    self.summaryTextView.font = font;
    self.summaryTextView.allowsEditingTextAttributes = NO;
    self.summaryTextView.editable = NO;
    self.summaryTextView.userInteractionEnabled = NO;
    self.summaryTextView.multipleTouchEnabled = YES;
    
    [self.scrollView addSubview:self.summaryTextView];
    self.scrollView.contentSize = scrollViewSize;
}

- (void)makeDeleteButton
{
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [deleteButton addTarget:self action:@selector(deleteMethod) forControlEvents:UIControlEventTouchDown];
    
    deleteButton.frame = CGRectMake(self.summaryTextView.frame.origin.x, self.scrollView.frame.size.height + self.summaryTextView.frame.size.height/2, 125, 50);
    
    [deleteButton setTitle:@"DELETE ITEM" forState:UIControlStateNormal];
    
    [self.scrollView addSubview:deleteButton];
    
}

- (void)deleteWithButton
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate deleteProduct];
    }];
}

#pragma mark -Button methods
- (IBAction)saveWithButton:(id)sender
{
    self.product.name = self.titleTextField.text;
    self.product.summary = self.summaryTextView.text;
    
    Price *wishPrice = [self.product priceWithType:sPriceTypeWish];
    wishPrice.dollarAmount = [NSNumber numberWithFloat:self.priceSlider.value];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate reloadProductDetails];
    }];
}

- (IBAction)cancelWithButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)adjustPrice:(id)sender
{
    self.wishPriceLabel.text = [NSString stringWithFormat:@"$%.2f", self.priceSlider.value];
}

#pragma mark -Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.destinationViewController isKindOfClass:[EditViewController class]]) {
        
        EditViewController *editViewController = segue.destinationViewController;
        
        editViewController.delegate = self;
        
        editViewController.currentTextViewString = self.summaryTextView.text;
        
    }
}

#pragma mark -Edit view delegate
- (void)updateTextViewWithText:(NSString *)text
{
    self.summaryTextView.text = text;
}

#pragma mark -Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
