//
//  Post.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/21/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "Post.h"
#import <Parse/Parse.h>

@implementation Post

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic likeCount;
@dynamic commentCount;
@dynamic likeArray;
@dynamic commentArray;
@dynamic squats;
@dynamic time;
@dynamic username;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postUserWithCaption: ( NSString * _Nullable )caption WithSquats: (NSNumber * _Nullable) squats WithTime: (NSNumber * _Nullable) time withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    
    Post *newPost = [Post new];
    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.likeArray = [NSMutableArray array];
    newPost.commentArray = [NSMutableArray array];
    newPost.squats = squats;
    newPost.time = time;
    newPost.username = PFUser.currentUser.username;
    [newPost saveInBackgroundWithBlock: completion];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName: @"image.png" data: imageData];
}

@end
