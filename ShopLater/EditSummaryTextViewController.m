//
//  EditViewController.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/13/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "EditSummaryTextViewController.h"

@interface EditSummaryTextViewController  ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)submitWithButton:(id)sender;
- (IBAction)cancelWithButton:(id)sender;

@end

@implementation EditSummaryTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.text = self.currentTextViewString;
    [self becomeFirstResponder];
    [self.textView selectAll:self];
    [UIMenuController sharedMenuController].menuVisible = NO;
}

- (IBAction)submitWithButton:(id)sender {
    
    if (self.textView.text.length > 3) {
        [self.delegate updateTextViewWithText:self.textView.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelWithButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
