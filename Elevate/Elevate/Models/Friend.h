//
//  Friend.h
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 8/6/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Friend : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSNumber *squats;
@property (nonatomic, strong) NSNumber *numLikes;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *imageUrl;

+ (NSMutableArray *)friendsWithArray:(NSArray *)dictionaries;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
-(NSURL *)getImage: (NSString *) imageURL;

@end

NS_ASSUME_NONNULL_END
