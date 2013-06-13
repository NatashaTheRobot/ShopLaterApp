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
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UITextView *summaryTextView;


- (IBAction)saveWithButton:(id)sender;
- (IBAction)cancelWithButton:(id)sender;
- (IBAction)adjustPrice:(id)sender;
- (IBAction)deleteWithButton:(id)sender;
- (IBAction)editDescriptionWithButton:(id)sender;


- (void)setupEditFields;

@end

@implementation EditProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self makeSummaryTextView];
    
    [self setupEditFields];
    
}

- (void)makeSummaryTextView
{
    
    CGSize size = [self.product.summary sizeWithFont:[UIFont systemFontOfSize:14]
                                   constrainedToSize:CGSizeMake(100, 2000)
                                       lineBreakMode:NSLineBreakByCharWrapping];
    
    self.summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.deleteButton.frame.origin.x, self.deleteButton.frame.origin.y + 50, self.view.frame.size.width - 100, size.height + 10)];
    
    
    CGSize scrollViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + (self.summaryTextView.frame.size.height/2));
    
    UIFont *font = [UIFont fontWithName:@"Georgia" size:14.0];
    
    [self.summaryTextView setFont:font];
    
    self.summaryTextView.allowsEditingTextAttributes = NO;
    self.summaryTextView.editable = NO;
    self.summaryTextView.userInteractionEnabled = YES;
    self.summaryTextView.multipleTouchEnabled = YES;
    
    [self.scrollView addSubview:self.summaryTextView];
    self.scrollView.contentSize = scrollViewSize;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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

- (IBAction)deleteWithButton:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate deleteProduct];
    }];
    
}

- (IBAction)editDescriptionWithButton:(id)sender {
    
    [self performSegueWithIdentifier:@"toEditView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toEditView"]) {
        
        EditViewController *editViewController = [segue destinationViewController];
        
        editViewController.editDelegate = self;
        
        editViewController.currentTextViewString = self.summaryTextView.text;
        
    }
}

#pragma mark -Edit view delegate
-(void)updateTextViewInDetailViewController:(NSString *)withString
{

    [self.summaryTextView setText:withString];
   
}

@end
