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
#import "ShopLaterAPI.h"

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
@property (weak, nonatomic) IBOutlet UIView *productDetailsView;


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
    
    self.productDetailsView.alpha = 0;
    
    [self displayProduct];
    
    [self.activityIndicator startAnimating];
    
    [self.slidingViewController setAnchorRightRevealAmount:sMenuAnchorRevealAmount];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
    [self customizeNavigationBar];
    
    [self setupScrollViewScrolling];
    
    [self setupShadows];
    
    self.priceSlider.minimumTrackTintColor = [UIColor colorWithRed:180/255.0 green:131/255.0 blue:171/255.0 alpha:1];
    
    //self.trackedViewName = [NSString stringWithFormat:@"NewProductViewController for product with URL: %@", self.productURLString];
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
    self.scrollView.backgroundColor = [UIColor colorWithRed:242/255.0 green:240/255.0 blue:242/255.0 alpha:1];
    if (self.view.frame.size.height >= self.contentView.frame.size.height) {
        self.scrollView.scrollEnabled = NO;
    } else {
        self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height + 57);
        [self.scrollView setContentOffset:CGPointMake(0, 57) animated:YES];
        self.scrollView.scrollEnabled = YES;
    }
}

- (void)setupShadows
{
    self.productDetailsView.layer.masksToBounds = NO;
    
    self.productDetailsView.layer.borderColor = [[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.3] CGColor];
    self.productDetailsView.layer.borderWidth = 1;
    self.productDetailsView.layer.cornerRadius = 4;
    self.productDetailsView.layer.shadowColor = [[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1] CGColor];
    self.productDetailsView.layer.shadowOffset = CGSizeMake(2, 2);
    self.productDetailsView.layer.shadowRadius = 1;
    self.productDetailsView.layer.shadowOpacity = 0.5;
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
                self.currentPriceLabel.text = [NSString stringWithFormat:@"Current Price:  %@",
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
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.productDetailsView.alpha = 1;
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
    
    // save item to API
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0l), ^{
        NSArray* users = [[CoreDataManager sharedManager] returnUsers];
        if (users.count == 0) return;
        User* user = [users objectAtIndex:0];
        NSDictionary* itemData = @{@"ogToken":user.identifier, @"provider":self.provider.name, @"itemName": [Product formattedName:[self.parser.delegate productName]], @"itemValue": [(Price *)[self.parser.delegate productPrice] dollarAmount], @"itemPrice": [NSNumber numberWithFloat:self.priceSlider.value], @"url": [self.parser.delegate cleanURLString], @"mobileUrl": [self.parser.delegate mobileURLString]};
        
        NSLog(@"%s [Line %d]\n%@", __PRETTY_FUNCTION__, __LINE__, itemData);
        
        [[ShopLaterAPI sharedInstance] requestWithData:[NSJSONSerialization dataWithJSONObject:itemData options:0 error:nil] type:@"follow"];
    });

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
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [self.coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
        nil;
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