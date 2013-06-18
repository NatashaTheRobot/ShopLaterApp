//
//  ButtonFactory.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/18/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "ButtonFactory.h"

@implementation ButtonFactory

+ (UIBarButtonItem *)barButtonItemWithImageName:(NSString *)imageName
                                         target:(id)target
                                         action:(SEL)action
{
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

@end
