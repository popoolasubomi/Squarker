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
    
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImage addGestureRecognizer: profileTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self.delegate homeCell:self didTap: self.post];
}

-(void)setPost:(Post *) post{
    _post = post;
    
    PFUser *user = self.post[@"author"];
    self.profileImage.layer.cornerRadius = 18;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.file = [user objectForKey: @"image"];
    [self.profileImage loadInBackground];
    self.usernameLabel.text = user != nil ? user.username : @"🤖";
    
    self.numberOfSquats.text = [NSString stringWithFormat: @"%@", post.squats];
    
    self.caption.text = post.caption;
}

- (void)setFriends:(PFUser *)friendName{
    _friendName = friendName;
    
    UIImage *image = [UIImage imageNamed: @"download"];
    self.profileImage.image = image;
    self.caption.text = [friendName objectForKey: @"description"];
    self.numberOfSquats.text = [NSString stringWithFormat: @"%d", [[friendName objectForKey: @"squats"] intValue]];
    self.usernameLabel.text = friendName.username;
}
@end
