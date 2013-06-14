//
//  WebViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "WebViewController.h"
#import "NewProductViewController.h"
#import "Identifier.h"
#import "CoreDataManager.h"

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *buyLaterButton;
@property (strong, nonatomic) NSMutableArray *toolbarButtons;

- (void)checkIfProductPage:(NSString *)urlString;
- (void)loadWebPage;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    
    [self loadWebPage];
    
    self.toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    [self hideBuyLaterButton];
    
}

- (void)hideBuyLaterButton
{
    [self.toolbarButtons removeObject:self.buyLaterButton];
    [self.navigationItem setRightBarButtonItems:self.toolbarButtons animated:NO];
}

- (void)showBuyLaterButton
{
    if (![self.toolbarButtons containsObject:self.buyLaterButton]) {
        [self.toolbarButtons addObject:self.buyLaterButton];
        [self.navigationItem setRightBarButtonItems:self.toolbarButtons animated:YES];
    }
}

- (void)loadWebPage
{
    NSString *urlString = self.product ? self.product.mobileURL : self.provider.url;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [self.webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.activityIndicator isAnimating]) {
        [self.activityIndicator stopAnimating];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self checkIfProductPage:webView.request.URL.absoluteString];
    });
}

- (void)checkIfProductPage:(NSString *)urlString
{
    BOOL providerPage = !([urlString rangeOfString:self.provider.name].location == NSNotFound);
    
    __block BOOL productPage = YES;
    
    [self.provider.identifiers enumerateObjectsUsingBlock:^(Identifier *identifier, BOOL *stop) {
        if ([urlString rangeOfString:identifier.name].location == NSNotFound) {
            productPage = NO;
            *stop = YES;
        }
    }];
    
    BOOL newProduct = [[CoreDataManager sharedManager] uniqueAttributeForClassName:NSStringFromClass([Product class])
                                                                     attributeName:@"mobileURL" attributeValue:urlString];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (providerPage && productPage && newProduct) {
            [self showBuyLaterButton];
        } else {
            [self hideBuyLaterButton];
        }
    });
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[NewProductViewController class]]) {
        NewProductViewController *newProductViewController = segue.destinationViewController;
        newProductViewController.productURLString = self.webView.request.URL.absoluteString;
        newProductViewController.provider = self.provider;
    }
    
}

@end
