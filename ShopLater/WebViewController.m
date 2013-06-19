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

@interface WebViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIBarButtonItem *buyLaterButton;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIView *topBarView;

- (IBAction)backWithButton:(id)sender;
- (IBAction)forwardWithButton:(id)sender;

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
    
    [[self.webView scrollView] setContentInset:UIEdgeInsetsMake(26, 0, 0, 0)];
    self.webView.scrollView.delegate = self;
    
    [self.activityIndicator startAnimating];
    
    [self loadWebPage];
    
    [self customizeNavigationBar];
    
    [self setupToolbarButtons];
    
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (IBAction)backWithButton:(id)sender
{
    [self.webView goBack];
}

- (IBAction)forwardWithButton:(id)sender
{
    [self.webView goForward];
}

- (void)customizeNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"nav_bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    self.buyLaterButton = [ButtonFactory barButtonItemWithImageName:@"buy_later_btn.png" target:self action:@selector(buyLaterAction)];
    self.navigationItem.rightBarButtonItem = self.buyLaterButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (![self.activityIndicator isAnimating]) {
        [self.activityIndicator startAnimating];
    }
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
    
    BOOL newProduct = [[CoreDataManager sharedManager] uniqueAttributeForClassName:NSStringFromClass([Product class])
                                                                     attributeName:@"mobileURL" attributeValue:urlString];
    
    BOOL lululemonCategory = [self.provider.name isEqualToString:@"lululemon"]  && [urlString containsString:@"category"];
    
    __block BOOL productPage = YES;
    
    [self.provider.identifiers enumerateObjectsUsingBlock:^(Identifier *identifier, BOOL *stop) {
        if ([urlString rangeOfString:identifier.name].location == NSNotFound) {
            productPage = NO;
            *stop = YES;
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (providerPage && productPage && newProduct) {
            if (lululemonCategory) {
                self.navigationItem.rightBarButtonItem.enabled = NO;
                return;
            }
            self.navigationItem.rightBarButtonItem.enabled = YES;
            return;
        }
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( scrollView.contentOffset.y >= -26 && scrollView.contentOffset.y < 26 )
    {
        self.topBarView.frame = CGRectMake(0, -26 - scrollView.contentOffset.y, 320, 26);
        
    } else if ( scrollView.contentOffset.y < -26) {
        self.topBarView.frame = CGRectMake(0, 0, 320, 26);
    }
}

@end
