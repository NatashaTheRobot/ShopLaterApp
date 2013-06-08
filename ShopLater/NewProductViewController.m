//
//  NewProductViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "NewProductViewController.h"

@interface NewProductViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation NewProductViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // get the info from url
    }
    
    return self;
}

- (void)parseURL
{
    NSArray *urlComponents = [self.productURLString componentsSeparatedByString:@"jsp%3F"];
    
    NSArray *paramPairs = [urlComponents[1] componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *urlParamsDictionary = [[NSMutableDictionary alloc] init];
    
    [paramPairs enumerateObjectsUsingBlock:^(NSString *paramPair, NSUInteger idx, BOOL *stop) {
        NSArray *paramKeyValue = [paramPair componentsSeparatedByString:@"%3D"];
        if ([paramKeyValue[0] isEqualToString:@"productId"]) {
            NSLog(@"product id = %@", paramKeyValue[1]);
            return;
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    
    [self parseURL];
	
}

@end
