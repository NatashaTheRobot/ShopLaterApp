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
#import "Constants.h"
#import "ECSlidingViewController.h"
#import "ButtonFactory.h"

@interface NewProductViewController ()


@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *priceSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;


@property (strong, nonatomic) CoreDataManager *coreDataManager;
@property (strong, nonatomic) Parser *parser;
@property (strong, nonatomic) Product *product;

- (IBAction)adjustWishPrice:(id)sender;

- (void)customizeNavigationBar;
- (void)goBack;
- (void)saveProduct;
- (void)displayProduct;
- (void)createProduct;

@end

@implementation NewProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    
    [self displayProduct];
    
    [self.slidingViewController setAnchorRightRevealAmount:sMenuAnchorRevealAmount];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
    [self customizeNavigationBar];
    
    [self setupScrollViewScrolling];
    
    self.priceSlider.minimumTrackTintColor = [UIColor colorWithRed:119/255.0 green:117/255.0 blue:119/255.0 alpha:1];
}

- (void)customizeNavigationBar
{    
    self.navigationItem.leftBarButtonItem = [ButtonFactory barButtonItemWithImageName:@"back_btn.png"
                                                                               target:self
                                                                               action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem = [ButtonFactory barButtonItemWithImageName:@"save_btn.png"
                                                                                target:self
                                                                                action:@selector(saveProduct)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupScrollViewScrolling
{
    if (self.view.frame.size.height >= self.contentView.frame.size.height) {
        self.scrollView.scrollEnabled = NO;
    } else {
        self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height + 50);
        self.scrollView.scrollEnabled = YES;
    }
}

- (void)displayProduct
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.parser = [Parser parserWithProviderName:self.provider.name productURLString:self.productURLString];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (self.parser == nil) {
                UIAlertView *alertParser = [[UIAlertView alloc] initWithTitle:@"Please try again!"
                                                                      message:@"Something went wrong, and we were unable to retrieve your product."
                                                                     delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil, nil];
                [alertParser show];
            } else {
                
                NSNumber *priceInDollars = [(Price *)[self.parser.delegate productPrice] dollarAmount];
                NSString *nameUnformatted = [self.parser.delegate productName];
                self.productNameLabel.text = [Product formattedName:nameUnformatted];
                self.currentPriceLabel.text = [NSString stringWithFormat:@"%@",
                                               [Price formattedPriceFromNumber:priceInDollars]];
                self.priceSlider.maximumValue = [priceInDollars floatValue];
                self.priceSlider.value = [priceInDollars floatValue] * 0.8;
                
                NSString *wishPrice = [Price formattedPriceFromNumber:[NSNumber numberWithFloat:([priceInDollars floatValue] * 0.8)]];
                self.wishPriceLabel.text = wishPrice;
                
                self.logoImageView.image = [Image imageForProvider:self.provider type:sImageTypeLogo];
                
                [self.view viewWithTag:1].alpha = 0;
                
                Image *image = [self.parser.delegate productImage];
                [image downloadImageFromURL:[NSURL URLWithString:image.externalURLString] completionBlock:^(BOOL succeeded, UIImage *image) {
                    self.imageView.image = image;
                    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                    [self.activityIndicator stopAnimating];
                    
                }];
                
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
        });
    });
}

- (void)createProduct
{
    NSDictionary *productDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[self.parser.delegate productName], @"name",
                                       [self.parser.delegate cleanURLString], @"url",
                                       self.provider, @"provider",
                                       [self.parser.delegate mobileURLString], @"mobileURL",
                                       [NSDate date], @"createdAt",
                                       [NSNumber numberWithInteger:1], @"priceLoadedInSession",
                                       nil];
    self.coreDataManager = [CoreDataManager sharedManager];
    
    self.product = [self.coreDataManager createEntityWithClassName:NSStringFromClass([Product class])
                                              attributesDictionary:productDictionary];
    
    [self.product addImagesObject:[self.parser.delegate productImage]];
    [self.product addPricesObject:[self.parser.delegate productPrice]];
    
    
}

- (void)saveProduct
{
    [self createProduct];
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

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (IBAction)adjustWishPrice:(UISlider *)slider
{
    NSString *formattedPrice = [Price formattedPriceFromNumber:[NSNumber numberWithFloat:slider.value]];
    self.wishPriceLabel.text = formattedPrice;
}

@end
