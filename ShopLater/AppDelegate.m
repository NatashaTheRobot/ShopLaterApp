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
#import "User.h"
#import "ShopLaterAPI.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(remoteNotif)
    {
        //Handle remote notification
        
        NSLog(@"remoteNotif = %@", remoteNotif);
    }
    
    self.window.backgroundColor = [UIColor colorWithRed:180/255.0 green:131/255.0 blue:171/255.0 alpha:1];
    
    return YES;
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

#pragma mark - push notifications
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    if (![[CoreDataManager sharedManager] coreDataHasEntriesForEntityName:@"User"]) {
        [[CoreDataManager sharedManager] createEntityWithClassName:@"User" attributesDictionary:@{@"identifier":deviceToken}];
        [[CoreDataManager sharedManager] saveDataInManagedContextUsingBlock:nil];
    }
    
    NSArray* users = [[CoreDataManager sharedManager] returnUsers];
    if (users.count == 0) return;
    User* user = [users objectAtIndex:0];
    NSDictionary* tokenData = @{@"ogToken":user.identifier, @"deviceToken":deviceToken};
    
    NSLog(@"%s [Line %d]\n%@", __PRETTY_FUNCTION__, __LINE__, tokenData);
    
    [[ShopLaterAPI sharedInstance] requestWithData:[NSJSONSerialization dataWithJSONObject:tokenData options:0 error:nil] type:@"token"];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"userInfo = %@\napplication = %@", userInfo, application);
    
    NSString* body = [[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"body"];
    
    NSString* channelName = [self scanString:body startTag:@"\'" endTag:@"\'"];
    
    NSLog(@"channelName = %@", channelName);
    
    NSArray* componentStrings = [body componentsSeparatedByString:@"\n"];
    
    NSLog(@"componentString = %@", componentStrings);
    
    NSString *mimeType = [[componentStrings[1] componentsSeparatedByString:@" "] objectAtIndex:0];
    
    NSString* payload = [self scanString:componentStrings[1] startTag:@"__:" endTag:@"__"];
    
    NSLog(@"payload = %@\nmimeType = %@", payload, mimeType);
    
    NSDictionary* payloadDictionary = @{mimeType:payload};
    
    NSLog(@"pauloadDictionary = %@", payloadDictionary);
    
    [self.notificationDelegateAppDelegate notificationsToDo:payloadDictionary];
    
    //    CFBundleRef bundleRef = CFBundleGetMainBundle();
    //    CFURLRef urlRef;
    //
    //    urlRef = CFBundleCopyResourceURL(bundleRef, (CFStringRef) @"notify", CFSTR ("wav"), NULL );
    //
    //    SystemSoundID soundResource;
    //    AudioServicesCreateSystemSoundID(urlRef, &soundResource);
    //    AudioServicesPlaySystemSound (soundResource);
    //    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (NSString *)scanString:(NSString *)string startTag:(NSString *)startTag endTag:(NSString *)endTag
{
    
    NSString* scanString = @"";
    
    if (string.length > 0) {
        
        NSScanner* scanner = [[NSScanner alloc] initWithString:string];
        
        @try {
            [scanner scanUpToString:startTag intoString:nil];
            scanner.scanLocation += [startTag length];
            [scanner scanUpToString:endTag intoString:&scanString];
        }
        @catch (NSException *exception) {
            return nil;
        }
        @finally {
            return scanString;
        }
        
    }
    
    
    return scanString;
    
}

@end
