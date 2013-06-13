//
//  EdiViewController.m
//  ShopLater
//
//  Created by Reza Fatahi on 6/12/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "EdiViewController.h"

@interface EdiViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)submitWithButton:(id)sender;

@end

@implementation EdiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.textView.text = self.currentTextViewString;
    [self becomeFirstResponder];
    [self.textView selectAll:self];
    [UIMenuController sharedMenuController].menuVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitWithButton:(id)sender {
    
    if (self.textView.text.length > 6) {
        //delegate method here
        [self.editDelegate updateTextViewInDetailViewController:self.textView.text];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
