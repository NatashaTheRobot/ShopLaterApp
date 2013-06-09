//
//  ProductErrorViewController.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/8/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "InformationViewController.h"
#import "Image.h"
#import "Image+SLExtensions.h"

@interface InformationViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)doneWithButton:(id)sender;

@end

@implementation InformationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = [Image imageForProvider:self.provider type:@"example"];
}


- (IBAction)doneWithButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
