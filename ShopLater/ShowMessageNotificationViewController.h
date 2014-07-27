//
//  ShowMessageNotificationViewController.h
//  pasadenacivicapp
//
//  Created by Rex Fatahi on 3/31/14.
//  Copyright (c) 2014 aug2uag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowMessageNotificationViewController : UIViewController

@property (strong, nonatomic) UITextView* textView;
@property (strong, nonatomic) UIView* textViewPaddingView;
@property (strong, nonatomic) UIWebView* webView;
@property (strong, nonatomic) UILabel* label;
@property (strong, nonatomic) NSString* webMediaUrl;
@property (strong, nonatomic) NSString* textPayload;

@property (assign) BOOL isWebViewMedia;

- (void)loadWebViewWithPayload:(NSString *)payload;

@end
