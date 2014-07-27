//
//  ShowMessageNotificationViewController.m
//  pasadenacivicapp
//
//  Created by Rex Fatahi on 3/31/14.
//  Copyright (c) 2014 aug2uag. All rights reserved.
//

#import "ShowMessageNotificationViewController.h"

@interface ShowMessageNotificationViewController () <UIWebViewDelegate>
{
    CGRect textViewportrait, textViewlandscape, padTextViewportrait, padTextViewlandscape;
    UIActivityIndicatorView* beachBall;
}

@end

@implementation ShowMessageNotificationViewController

- (void)loadView
{
    [super loadView];
    
    if (!_isWebViewMedia) {
        padTextViewportrait = CGRectMake(20, 44, self.view.bounds.size.width - 40, self.view.bounds.size.height - 88);
        padTextViewlandscape = CGRectMake(20, 22, self.view.bounds.size.height - 44, self.view.bounds.size.width - 40);
        
        UIButton* exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        exitButton.frame = CGRectMake(20, 20, 60, 60);
        [exitButton  setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [exitButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:exitButton];
        exitButton.backgroundColor = [UIColor clearColor];
        
        _textView = [[UITextView alloc] initWithFrame:padTextViewportrait];
        _textView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_textView];
        _textView.editable = NO;
        NSMutableString * displayString = [NSMutableString stringWithString:@"\n\n\n"];
        [displayString appendString:_textPayload];
        _textView.text = displayString;
        _textView.textColor = [UIColor whiteColor];
        _textView.font = [UIFont fontWithName:@"HelveticaBold" size:24.0f];
        
        
        UIFont* fontTV = [UIFont fontWithName:@"Helvetica" size:15.0f];
        _textView.font = fontTV;
        
        [self.view bringSubviewToFront:exitButton];

    }
    
    self.view.backgroundColor = [UIColor colorWithHue:0.8 saturation:0.4 brightness:0.5 alpha:0.6f];
    
}

- (void)loadWebViewWithPayload:(NSString *)payload
{
    if (_isWebViewMedia) {
        
        NSString* urlString = [NSString stringWithFormat:@"%@", payload];
        urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        UIButton* exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        exitButton.frame = CGRectMake(20, 20, 60, 60);
        [exitButton  setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [exitButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:exitButton];
        exitButton.backgroundColor = [UIColor clearColor];
        
        NSLog(@"yooo!!");
        
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        [self.view addSubview:_webView];
        
        beachBall = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        beachBall.color = [UIColor redColor];
        beachBall.center = self.view.center;
        [_webView addSubview:beachBall];
        
        NSURL* url = [NSURL URLWithString:urlString];
        
        NSLog(@"string = %@\n\nurl = %@", urlString, url);
        
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        
        NSLog(@"request = %@", request);
        
        [beachBall startAnimating];
        [_webView loadRequest:request];
        
        [self.view bringSubviewToFront:exitButton];
        
        return;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self detectOrientation];
}

-(void) detectOrientation {
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)) {
        [self.webView setFrame:self.view.bounds];
    }  else {
        [self.webView setFrame:self.view.bounds];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [beachBall stopAnimating];
}

- (void)exit
{
    [self dismissViewControllerAnimated:YES completion:^{
        _webView = nil;
        _textView = nil;
    }];
}

@end
