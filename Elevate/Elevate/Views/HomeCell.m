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
    
    self.profileImage.file = post.image;
    [self.profileImage loadInBackground];
    
    PFUser *user = self.post[@"author"];
    self.usernameLabel.text = user != nil ? user.username : @"🤖";
    
    self.numberOfSquats.text = [NSString stringWithFormat: @"%@", post.squats];
    
    self.caption.text = post.caption;
}

@end
