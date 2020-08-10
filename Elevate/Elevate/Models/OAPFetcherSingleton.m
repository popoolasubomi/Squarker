//
//  OAPFetcherSingleton.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/31/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "OAPFetcherSingleton.h"
#import "Parse/Parse.h"

@implementation OAPFetcherSingleton

+ (OAPFetcherSingleton *)sharedObject {
    static OAPFetcherSingleton *sharedClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClass = [[self alloc] init];
    });
    return sharedClass;
}

- (void) fetchStatusLevel {
    PFUser *user = PFUser.currentUser;
    NSArray *stages = @[@"Novice", @"Beginner", @"Competent", @"Proficient", @"Expert"];
    NSArray *minimum_req = @[@(50), @(150), @(300), @(500), @(750)];
    
    NSNumber *squats = [user objectForKey: @"squats"];
    int i = 0;
    while (i < stages.count){
        if (squats.intValue < [minimum_req[i] intValue]){
            [user setObject: stages[i] forKey: @"status"];
            i += stages.count;
        }
        i ++;
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {}];
}
@end
