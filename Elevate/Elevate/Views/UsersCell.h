//
//  UsersCell.h
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/31/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface UsersCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (nonatomic, strong) Post *user;

@end

NS_ASSUME_NONNULL_END
