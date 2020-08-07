//
//  Friend.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 8/6/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "Friend.h"
@import Parse;

@implementation Friend

+ (NSMutableArray *)friendsWithArray:(NSArray *)dictionaries{
    NSMutableArray *friends = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Friend *friend = [[Friend alloc] initWithDictionary: dictionary];
        [friends addObject: friend];
    }
    return friends;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.username = dictionary[@"username"];
        self.squats = dictionary[@"squats"];
        self.numLikes = dictionary[@"likes"];
        self.caption = dictionary[@"description"];
        self.imageUrl = dictionary[@"image"];
    }
    return self;
}

- (NSDictionary *)BuildWithPFUser:(PFUser *)dictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *keys1 = @[@"username",  @"description"]; //Strings
    NSArray *keys2 = @[@"squats", @"likes"];  //NSNumber
    NSArray *keys3 = @[@"image"];   // PFFileObject
    if (dictionary) {
        for (NSString *key in keys1){
            if (dictionary[key] != nil){
                [result setObject: dictionary[key] forKey: key];
            } else{
                [result setObject: @"" forKey: key];
            }
        }
        for  (NSString *key in keys2){
            if (dictionary[key] != nil){
                [result setObject: dictionary[key] forKey: key];
            } else{
                [result setObject: [NSNumber numberWithInt: 0] forKey: key];
            }
        }
        for  (NSString *key in keys3){
            if (dictionary[key] != nil){
                PFFileObject *imageData = dictionary[key];
                [result setObject: [NSString stringWithFormat: @"%@", imageData.url] forKey: key];
            } else{
                [result setObject: @"" forKey: key];
            }
        }
    }
    return result;
}

-(NSURL *)getImage: (NSString *) imageURL{
    return [NSURL URLWithString: imageURL];
}

@end
