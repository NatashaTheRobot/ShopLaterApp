//
//  AppDelegate.h
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationsAction <NSObject>

- (void)notificationsToDo:(NSDictionary *)payload;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id <NotificationsAction> notificationDelegateAppDelegate;

@end
