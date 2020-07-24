//
//  UsersProfileViewController.h
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface UsersProfileViewController : UIViewController

@property (nonatomic, strong) Post* post;

@end

NS_ASSUME_NONNULL_END
