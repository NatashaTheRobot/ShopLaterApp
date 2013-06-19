//
//  AppDelegate.m
//  ShopLater
//
//  Created by Natasha Murashev on 6/7/13.
//  Copyright (c) 2013 Natasha Murashev. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataManager.h"
#import "Product.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"HasLaunchedOnce"]) {
        [userDefaults setInteger:1 forKey:@"LaunchTime"];
    }
    else {
        [userDefaults setBool:YES forKey:@"HasLaunchedOnce"];
        [userDefaults setInteger:0 forKey:@"LaunchTime"];
        [userDefaults synchronize];
        // This is the first launch ever
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // error
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    CoreDataManager *coreDataManager = [CoreDataManager sharedManager];
    
    NSFetchedResultsController *fetchedResultsController = [coreDataManager fetchEntitiesWithClassName:NSStringFromClass([Product class])
                                                sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]
                                             sectionNameKeyPath:nil
                                                      predicate:nil];
    
    [fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(Product *product, NSUInteger idx, BOOL *stop) {
        product.priceLoadedInSession = [NSNumber numberWithInteger:0];
    }];
    
    [coreDataManager saveDataInManagedContextUsingBlock:^(BOOL saved, NSError *error) {
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
