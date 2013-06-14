//
//  LeftPanelViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeftPanelViewControllerDelegate <NSObject>

@required
- (void)storeSelected;

@end

@interface LeftPanelViewController : UIViewController

@property (nonatomic, assign) id<LeftPanelViewControllerDelegate> delegate;

@end
