//
//  AppDelegate.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/15/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
@import GoogleMaps;

NSString *const API_KEY = @"AIzaSyBry432Sv7KgjNmA33gohQ8b1P6QSTrhAo";
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration   configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
             configuration.applicationId = @"myAppId";
             configuration.server = @"https://ilevate.herokuapp.com/parse";
         }];
    [Parse initializeWithConfiguration: config];
    [GMSServices provideAPIKey: API_KEY];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
