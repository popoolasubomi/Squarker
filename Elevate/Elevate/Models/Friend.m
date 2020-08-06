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
        PFFileObject *imageData = dictionary[@"image"];
        self.imageUrl = [NSString stringWithFormat: @"%@", imageData.url];
    }
    return self;
}

-(NSURL *)getImage: (NSString *) imageURL{
    return [NSURL URLWithString: imageURL];
}

@end
