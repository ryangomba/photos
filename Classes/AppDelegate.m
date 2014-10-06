//
//  AppDelegate.m
//  Photos
//
//  Created by Ryan Gomba on 10/3/14.
//  Copyright (c) 2014 Ryan Gomba. All rights reserved.
//

#import "AppDelegate.h"

#import "RGShakeWindow.h"
#import "PhotoImporter.h"
#import "TabBarController.h"
#import "InboxViewController.h"
#import "EventsListViewController.h"
#import "TopicsListViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[PhotoImporter sharedPhotoImporter] importPhotos];
    
    self.window = [[RGShakeWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    InboxViewController *inboxVC = [[InboxViewController alloc] init];
    EventsListViewController *eventsVC = [[EventsListViewController alloc] init];
    TopicsListViewController *topicsVC = [[TopicsListViewController alloc] init];
    NSArray *viewControllers = @[inboxVC, eventsVC, topicsVC];
    TabBarController *tabBarController = [[TabBarController alloc] initWithViewControllers:viewControllers];
    
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //
}

@end
