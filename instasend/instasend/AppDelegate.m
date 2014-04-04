//
//  AppDelegate.m
//  instasend
//
//  Created by sdickson on 1/7/14.
//  Copyright (c) 2014 dickson. All rights reserved.
//

#import "AppDelegate.h"
#import "AppController.h"
#import "BluetoothAppController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:124.0/255 green:116.0/255 blue:98.0/255 alpha:1.0]];
    [BluetoothAppController sharedInstance];
    
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  //  [[[AppController sharedInstance] serviceAdvertiser] stopAdvertisingPeer];
  //  [[[AppController sharedInstance] browser] stopBrowsingForPeers];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    [[[AppController sharedInstance] devices] removeAllObjects];
    [[AppController sharedInstance] initialize];
    

}

- (void)applicationWillTerminate:(UIApplication *)application
{
  //  [[[AppController sharedInstance] serviceAdvertiser] stopAdvertisingPeer];
  //  [[[AppController sharedInstance] browser] stopBrowsingForPeers];
    
}

@end
