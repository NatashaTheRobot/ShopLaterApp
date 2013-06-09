//
//  CreateProductViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "NewProductViewController.h"

@interface NewProductViewController ()

@property (weak, nonatomic) IBOutlet UITextView *productTitleTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *priceSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *wishPriceLabel;

- (IBAction)saveProductWithButton:(id)sender;
@end

@implementation NewProductViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        //
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//- (void)parseURL
//{
//    NSArray *urlComponents = [self.productURLString componentsSeparatedByString:@"jsp%3F"];
//    
//    NSArray *paramPairs = [urlComponents[1] componentsSeparatedByString:@"&"];
//    
//    NSMutableDictionary *urlParamsDictionary = [[NSMutableDictionary alloc] init];
//    
//    [paramPairs enumerateObjectsUsingBlock:^(NSString *paramPair, NSUInteger idx, BOOL *stop) {
//        NSArray *paramKeyValue = [paramPair componentsSeparatedByString:@"%3D"];
//        if ([paramKeyValue[0] isEqualToString:@"productId"]) {
//            NSLog(@"product id = %@", paramKeyValue[1]);
//            return;
//        }
//    }];
//}

- (IBAction)saveProductWithButton:(id)sender
{
    // use delegate so the products view controller reloads table view data
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
