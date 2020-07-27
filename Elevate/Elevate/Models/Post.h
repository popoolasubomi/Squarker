//
//  Post.h
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/21/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSMutableArray *likeArray;
@property (nonatomic, strong) NSMutableArray *commentArray;
@property (nonatomic, strong) NSNumber *squats;
@property (nonatomic, strong) NSNumber *time;

+ (void) postUserWithCaption: ( NSString * _Nullable )caption WithSquats: (NSNumber * _Nullable) squats WithTime: (NSNumber * _Nullable) time withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
