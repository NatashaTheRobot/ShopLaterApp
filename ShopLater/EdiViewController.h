//
//  EdiViewController.h
//  ShopLater
//
//  Created by Reza Fatahi on 6/12/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditDelegate <NSObject>

- (void)updateTextViewInDetailViewController:(NSString *)withString;

@end

@interface EdiViewController : UIViewController

@property (weak, nonatomic) NSString *currentTextViewString;
@property (strong, nonatomic) id <EditDelegate> editDelegate;

@end
