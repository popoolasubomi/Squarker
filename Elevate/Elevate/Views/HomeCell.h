//
//  HomeCell.h
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol HomeCellDelegate;

@interface HomeCell : UITableViewCell

@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) PFUser *friendName;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSquats;
-(void)setPost:(Post *)post;
-(void)setFriends:(PFUser *)friendName;
@property (nonatomic, weak) id<HomeCellDelegate> delegate;

@end

@protocol HomeCellDelegate

- (void)homeCell:(HomeCell *) homeCell didTap: (Post *) post;

@end

NS_ASSUME_NONNULL_END
