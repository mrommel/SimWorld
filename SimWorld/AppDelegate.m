//
//  AppDelegate.m
//  SimWorld
//
//  Created by Michael Rommel on 04.10.14.
//  Copyright (c) 2014 Michael Rommel. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"
#import "LauncherViewController.h"
#import "UIConstants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // add custom navigation bar
    UIImage *navBackgroundImage = [UIImage imageNamed:@"navbar_bg"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary* navigationBarAttr = [[NSMutableDictionary alloc] init];
    [navigationBarAttr setValue:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]
                         forKey:NSForegroundColorAttributeName];
    [navigationBarAttr setValue:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0]
                         forKey:NSFontAttributeName];
    
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
    [shadow setShadowOffset: CGSizeMake(0.0f, 1.0f)];
    [navigationBarAttr setValue:shadow
                         forKey:NSShadowAttributeName];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navigationBarAttr];
    
    // Change the appearance of back button
    UIImage *backButtonImage = [[UIImage imageNamed:@"button_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, 0) forBarMetrics:UIBarMetricsDefault];
    
    // Change the appearance of other navigation button
    UIImage *barButtonImage = [[UIImage imageNamed:@"button_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, 0) forBarMetrics:UIBarMetricsDefault];
    
    [UIBarButtonItem appearance].tintColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    [[UIView appearance] setTintColor:[UIColor whiteColor]];
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    PRINT_RECT(@"screen bounds", [[UIScreen mainScreen] bounds]);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor lightGrayColor];
    
    LauncherViewController *viewController = [[LauncherViewController alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navigation;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
