//
//  WebViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "WebViewController.h"
#import "NewProductViewController.h"

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
    NSString *urlString = self.product ? self.product.url : self.provider.url;
    
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
    BOOL productPage = !([urlString rangeOfString:self.provider.identifierName].location == NSNotFound);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.product) {
            BOOL productURL = !([urlString rangeOfString:self.product.mobileURL].location == NSNotFound);
            if (productURL) {
                [self hideBuyLaterButton];
                return;
            }
        }
        
        if (providerPage && productPage) {
            [self showBuyLaterButton];
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
