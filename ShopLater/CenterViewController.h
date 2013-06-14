//
//  CenterViewController.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/14/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftPanelViewController.h"

@protocol CenterViewControllerDelegate <NSObject>

@optional
- (void)movePanelLeft;

@required
- (void)movePanelToOriginalPosition;

@end

@interface CenterViewController : UIViewController <LeftPanelViewControllerDelegate>

@property (nonatomic, assign) id<CenterViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end
