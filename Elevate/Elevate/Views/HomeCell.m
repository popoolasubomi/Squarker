//
//  HomeCell.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/22/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "HomeCell.h"
#import "Post.h"

@implementation HomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPost:(Post *) post{
    _post = post;
    
    self.profileImage.layer.cornerRadius = 18;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.file = post.image;
    [self.profileImage loadInBackground];
    
    PFUser *user = self.post[@"author"];
    self.usernameLabel.text = user != nil ? user.username : @"🤖";
    
    self.numberOfSquats.text = [NSString stringWithFormat: @"%@", post.squats];
    
    self.caption.text = post.caption;
}

- (void)setFriends:(NSString *)friendName{
    _friendName = friendName;
    
    CGRect newFrame = self.caption.frame;
    newFrame.origin.y += 50;
    newFrame.size.height = 21;
    
    self.caption.alpha = 0;
    self.usernameLabel.frame = newFrame;
}
@end
