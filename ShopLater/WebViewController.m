//
//  WebViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
    
- (IBAction)buyLaterWithButton:(id)sender;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    
    [self.webView loadRequest:request];
}

- (IBAction)buyLaterWithButton:(id)sender
{
    NSString *url = self.webView.request.URL.absoluteString;
    NSLog(@"%@", url);
}
@end
