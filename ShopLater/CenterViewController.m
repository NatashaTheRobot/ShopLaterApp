//
//  CenterViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "CenterViewController.h"

@interface CenterViewController ()

- (IBAction)showLeftPanelWithButton:(id)sender;

@end

@implementation CenterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (IBAction)showLeftPanelWithButton:(UIButton *)button
{
	switch (button.tag) {
		case 0: {
			[self.delegate movePanelToOriginalPosition];
			break;
		}
		case 1: {
			[self.delegate movePanelLeft];
			break;
		}
		default:
			break;
	}

}
@end
