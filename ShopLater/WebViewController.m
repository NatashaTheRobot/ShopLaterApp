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
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ButtonFactory.h"
#import "NSString+SLExtensions.h"

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIBarButtonItem *buyLaterButton;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) NSMutableArray *toolbarButtonsRight;

- (void)customizeNavigationBar;
- (void)goBack;
- (void)buyLaterAction;
- (void)addLogoToNavigationBar;

- (void)checkIfProductPage:(NSString *)urlString;
- (void)loadWebPage;
- (void)setupToolbarButtons;
- (void)revealMenu;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    
    [self customizeNavigationBar];
    
    [self setupToolbarButtons];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadWebPage];
    
    [super viewWillAppear:animated];
    
    self.view.layer.shadowOpacity = 0.8f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MenuViewController class])];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    [self addLogoToNavigationBar];
}

- (void)customizeNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"nav_bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    self.buyLaterButton = [ButtonFactory barButtonItemWithImageName:@"buy_later_btn.png" target:self action:@selector(buyLaterAction)];
    [self.navigationItem setRightBarButtonItem:self.buyLaterButton];
}

- (void)addLogoToNavigationBar
{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIImage *logoImage = [UIImage imageNamed:@"logo.png"];
    self.logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(navigationBar.frame.size.width / 2.0f - logoImage.size.width/2, 0, logoImage.size.width, navigationBar.frame.size.height)];
    self.logoImageView.image = logoImage;
    
    [self.navigationController.navigationBar addSubview:self.logoImageView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.logoImageView removeFromSuperview];
}


- (void)setupToolbarButtons
{
    self.toolbarButtonsRight = [self.navigationItem.rightBarButtonItems mutableCopy];
    [self hideBuyLaterButton];
    
    if (self.fromMenu) {
        UIBarButtonItem *menuButton = [ButtonFactory barButtonItemWithImageName:@"menu_btn.png"
                                                                                   target:self
                                                                                   action:@selector(revealMenu)];
        
        [self.navigationItem setLeftBarButtonItems:@[menuButton] animated:NO];
    } else {
        UIBarButtonItem *backButton = [ButtonFactory barButtonItemWithImageName:@"back_btn.png"
                                                                         target:self
                                                                         action:@selector(goBack)];
        [self.navigationItem setLeftBarButtonItems:@[backButton] animated:YES];
    }
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buyLaterAction
{
    [self performSegueWithIdentifier:@"toNewProduct" sender:self];
}

- (void)revealMenu
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
    ((MenuViewController *)self.slidingViewController.underLeftViewController).selectedProvider = self.provider;
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)hideBuyLaterButton
{
    [self.toolbarButtonsRight removeObject:self.buyLaterButton];
    [self.navigationItem setRightBarButtonItems:self.toolbarButtonsRight animated:NO];
}

- (void)showBuyLaterButton
{
    if (![self.toolbarButtonsRight containsObject:self.buyLaterButton]) {
        [self.toolbarButtonsRight addObject:self.buyLaterButton];
        [self.navigationItem setRightBarButtonItems:self.toolbarButtonsRight animated:YES];
    }
}

- (void)loadWebPage
{
    NSString *urlString;
    
    if (self.product) {
        urlString = self.product.mobileURL;
    } else {
        urlString = self.provider.url;
        self.fromMenu = YES;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [self.webView loadRequest:request];
}

- (void)reloadWebViewWithURL:(NSURL *)url
{
    [self.activityIndicator startAnimating];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
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
    
    
    if ([self.provider.name isEqualToString:@"lululemon"]) {
        NSString *urlLululemonPage = self.webView.request.URL.absoluteString;
        if ([urlLululemonPage containsString:@"category"]) {
            [self hideBuyLaterButton];
        } else if (![urlLululemonPage containsString:@"category"]) {
            [self showBuyLaterButton];
        }
    } else {
        
        BOOL providerPage = !([urlString rangeOfString:self.provider.name].location == NSNotFound);
        
        BOOL newProduct = [[CoreDataManager sharedManager] uniqueAttributeForClassName:NSStringFromClass([Product class])
                                                                         attributeName:@"mobileURL" attributeValue:urlString];
        
        __block BOOL productPage = YES;
        
        [self.provider.identifiers enumerateObjectsUsingBlock:^(Identifier *identifier, BOOL *stop) {
            if ([urlString rangeOfString:identifier.name].location == NSNotFound) {
                productPage = NO;
                *stop = YES;
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (providerPage && productPage && newProduct) {
                [self showBuyLaterButton];
            } else {
                [self hideBuyLaterButton];
            }
        });
    }
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
