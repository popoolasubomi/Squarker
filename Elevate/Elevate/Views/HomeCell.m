//
//  HomeCell.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "HomeCell.h"
#import "Post.h"
#import "UIImageView+AFNetworking.h"

NSString *const redHearts = @"favor-icon-red";
NSString *const normalHearts = @"favor-icon";

@implementation HomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *likeTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didDoubleTapUserProfile:)];
    likeTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.cellView addGestureRecognizer: likeTapGestureRecognizer];
    [self.cellView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *detailsTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapDetails:)];
    detailsTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.cellView addGestureRecognizer: detailsTapGestureRecognizer];
    [self.cellView setUserInteractionEnabled:YES];
    
    [detailsTapGestureRecognizer requireGestureRecognizerToFail: likeTapGestureRecognizer];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) didTapDetails:(UITapGestureRecognizer *)sender{
    [self.delegate homeCell:self didTap: self.post];
}

-(void) didDoubleTapUserProfile:(UITapGestureRecognizer *)sender{
    [self configureLikeFeatures];
}

- (void) configureLikeFeatures{
    PFUser *user = [PFUser currentUser];
    NSNumber *numLikes = [self.post objectForKey: @"likeCount"];
    self.likes = [self.post objectForKey: @"likeArray"];
    if (!self.likes){
        self.likes = [NSMutableArray array];
    }
    if (![self.likes containsObject: user.username]){
        [self.likes addObject: user.username];
        self.post.likeArray = self.likes;
        self.post.likeCount = [NSNumber numberWithInt: numLikes.intValue + 1];
    } else{
        [self.likes removeObject: user.username];
        self.post.likeArray = self.likes;
        self.post.likeCount = [NSNumber numberWithInt: numLikes.intValue - 1];
    }
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Updated Likes");
            [self updateHeartImage];
        }
        else {
            NSLog(@"Failed to Like");
        }
    }];
}

- (void) updateHeartImage{
    PFUser *user = [PFUser currentUser];
    [self.post fetchInBackground];
    self.likes = [self.post objectForKey: @"likeArray"];
    if ([self.likes containsObject: user.username]){
        self.likeImage.image = [UIImage imageNamed: redHearts];
    } else{
        self.likeImage.image = [UIImage imageNamed: normalHearts];
    }
    self.numLikes.text = [NSString stringWithFormat: @"%d", self.post.likeCount.intValue];
}

-(void)setPost:(Post *) post{
    _post = post;
    
    PFUser *user = self.post[@"author"];
    self.profileImage.layer.cornerRadius = 18;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.image = [UIImage imageNamed: @"download"];
    self.cellView.layer.cornerRadius = 19;
    self.cellView.layer.masksToBounds = NO;
    self.cellView.layer.shadowOffset = CGSizeMake(-5, 10);
    self.cellView.layer.shadowRadius = 2;
    self.cellView.layer.shadowOpacity = 0.5;
    self.profileImage.file = [user objectForKey: @"image"];
    [self.profileImage loadInBackground];
    self.usernameLabel.text = user != nil ? [NSString stringWithFormat: @"@%@", user.username] : @"🤖";
    self.numberOfSquats.text = [NSString stringWithFormat: @"%@ squats", post.squats];
    self.caption.text = post.caption;
    [self updateHeartImage];
}

- (void)setFriends:(Friend *)friendName{
    _friendName = friendName;
    UIImage *image = [UIImage imageNamed: @"download"];
    NSURL *imageURL = [[Friend alloc] getImage: friendName.imageUrl];
    [self.profileImage setImageWithURL: imageURL];
    if (self.profileImage.image == nil){
        self.profileImage.image = image;
    }
    self.profileImage.layer.cornerRadius = 18;
    self.profileImage.layer.masksToBounds = YES;
    self.caption.text = friendName.caption;
    self.numberOfSquats.text = [NSString stringWithFormat: @"%d squats", friendName.squats.intValue];
    self.usernameLabel.text = [NSString stringWithFormat: @"@%@", friendName.username];
    self.likeImage.alpha = 0;
    self.numLikes.alpha = 0;
}

@end
