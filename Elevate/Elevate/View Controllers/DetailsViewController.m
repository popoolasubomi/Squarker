//
//  DetailsViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/28/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "DetailsViewController.h"
#import "Parse/Parse.h"
#import "CommentCell.h"

@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numSquatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *commentsView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic) CGRect previousCommentFrame;
@property (nonatomic) CGRect previousTableFrame;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchComments];
    self.textField.alpha = 1;
}

- (void) fetchComments{
    self.comments = [self.post objectForKey: @"commentArray"];
//    if (self.comments.count == 0){
//        self.commentsView.alpha = 0;
//        self.tableView.alpha = 0;
//    }else{
//        [self.tableView reloadData];
//    }
}

- (IBAction)favoriteButton:(id)sender {
    
}

- (IBAction)postComment:(id)sender {
    self.tableView.alpha = self.tableView.alpha == 0 ? 1 : 0;
}

- (IBAction)viewComments:(id)sender {
    [UIView animateWithDuration: 0.5 animations:^{
        CGRect newFrame = self.commentsView.frame;
        CGFloat y = self.usernameLabel.frame.origin.y;
        newFrame.origin.y = y;
        
        self.textField.alpha = self.textField.alpha == 1 ? 0 : 1;
        self.usernameLabel.alpha = self.usernameLabel.alpha == 1 ? 0 : 1;
        self.captionLabel.alpha = self.captionLabel.alpha == 1 ? 0 : 1;
        self.numSquatsLabel.alpha =  self.numSquatsLabel.alpha == 1 ? 0 : 1;
        self.timeLabel.alpha = self.timeLabel.alpha == 1 ? 0 : 1;
        self.likeButton.alpha = self.likeButton.alpha == 1 ? 0 : 1;
        self.likesCount.alpha = self.likesCount.alpha == 1 ? 0 : 1;
        self.commentsCount.alpha = self.commentsCount.alpha == 1 ? 0 : 1;
        self.commentButton.alpha = self.commentButton.alpha == 1 ? 0 : 1;

        if (self.usernameLabel.alpha == 0){
            self.previousCommentFrame = self.commentsView.frame;
            self.previousTableFrame = self.tableView.frame;
            self.commentsView.frame = newFrame;
            newFrame = self.view.frame;
            y = self.commentsView.frame.origin.y + self.commentsView.frame.size.height;
            newFrame.origin.y = y;
            newFrame.size.height -= y;
            self.tableView.frame = newFrame;
        } else{
            NSLog(@"ELSE");
            self.commentsView.frame = self.previousCommentFrame;
            self.tableView.frame = self.previousTableFrame;
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CommentCell" forIndexPath: indexPath];
    cell.commentLabel.text = self.comments[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

@end
