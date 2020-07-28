//
//  DetailsViewController.h
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/28/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

@property(nonatomic, strong) Post *post;

@end

NS_ASSUME_NONNULL_END
