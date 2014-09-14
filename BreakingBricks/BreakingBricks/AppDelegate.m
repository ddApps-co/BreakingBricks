//
//  AppDelegate.m
//  BreakingBricks
//
//  Created by Dulio Denis on 8/31/14.
//  Copyright (c) 2014 Dulio Denis. All rights reserved.
//

#import "AppDelegate.h"
#import "ALSdk.h"

@implementation AppDelegate							

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ALSdk initializeSdk];
    return YES;
}

@end
