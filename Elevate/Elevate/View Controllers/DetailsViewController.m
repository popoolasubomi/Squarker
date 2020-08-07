//
//  DetailsViewController.m
//  Elevate
//
//  Created by Ogo-Oluwasobomi Popoola on 7/28/20.
//  Copyright © 2020 Ogo-Oluwasobomi Popoola. All rights reserved.
//

#import "DetailsViewController.h"
#import "UsersProfileViewController.h"
#import "SceneDelegate.h"
#import "Parse/Parse.h"
#import "CommentCell.h"
@import Parse;

NSString *const redHeart = @"favor-icon-red";
NSString *const normalHeart = @"favor-icon";

@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
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
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *likes;
@property (nonatomic) CGRect previousCommentFrame;
@property (nonatomic) CGRect previousTableFrame;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchComments];
    [self addTapRecognizer];
    
}

- (void) fetchComments{
    [self populateView];
    self.comments = [self.post objectForKey: @"commentArray"];
    if (self.comments.count == 0){
        self.commentsView.alpha = 0;
        self.tableView.alpha = 0;
    }else{
        [self.tableView reloadData];
    }
}

-(void) addTapRecognizer{
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapProfile:)];
    [self.profileImage addGestureRecognizer: profileTapGestureRecognizer];
    [self.profileImage setUserInteractionEnabled: YES];
}

-(void) didTapProfile:(UITapGestureRecognizer *)sender{
    [self performSegueWithIdentifier: @"profileSegue" sender: nil];
}


- (void) populateView{
    PFUser *postUser = [self.post objectForKey: @"author"];
    self.likes = [self.post objectForKey: @"likeArray"];
    self.usernameLabel.text = [NSString stringWithFormat: @"@%@", postUser.username];
    NSNumber *numSquats = [self.post objectForKey: @"squats"];
    self.numSquatsLabel.text = [NSString stringWithFormat: @"%d squats", numSquats.intValue];
    self.captionLabel.text = [self.post objectForKey: @"caption"];
    NSNumber *time = [self.post objectForKey: @"time"];
    self.timeLabel.text = [NSString stringWithFormat: @"Time: %d mins@", time.intValue];
    NSNumber *commentsCount = [self.post objectForKey: @"commentCount"];
    self.commentsCount.text = [NSString stringWithFormat: @"%d", commentsCount.intValue];
    PFFileObject *imageData = [postUser objectForKey: @"image"];
    self.profileImage.image = [UIImage imageNamed: @"download"];
    self.profileImage.file = imageData;
    self.profileImage.layer.cornerRadius = 76;
    self.profileImage.layer.masksToBounds = YES;
    [self.profileImage loadInBackground];
    [self updateHeartImage];
}

- (void) updateHeartImage{
    PFUser *user = [PFUser currentUser];
    if ([self.likes containsObject: user.username]){
        [self.likeButton setImage: [UIImage imageNamed: redHeart] forState: UIControlStateNormal];
    } else{
        [self.likeButton setImage: [UIImage imageNamed: normalHeart] forState: UIControlStateNormal];
    }
    self.likesCount.text = [NSString stringWithFormat: @"%d", self.post.likeCount.intValue];
}

- (void) configureLikeFeatures{
    PFUser *user = [PFUser currentUser];
    NSNumber *numLikes = [self.post objectForKey: @"likeCount"];
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

- (IBAction)favoriteAndUnFavoriteButton:(id)sender {
    [self configureLikeFeatures];
}

- (IBAction)postComment:(id)sender {
    [self buildCommentController];
}

- (void) buildCommentController{
    UIViewController* commentViewController = [UIViewController new];
    commentViewController.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = commentViewController.view.frame;
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 170, 20)];
    [instructionLabel setTextColor:[UIColor darkGrayColor]];
    [instructionLabel setBackgroundColor:[UIColor clearColor]];
    [instructionLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 17.0f]];
    [instructionLabel setText:@"Add your comment..."];
    [commentViewController.view addSubview: instructionLabel];
    
    self.textView = [[UITextView alloc] initWithFrame: CGRectMake(30, 65, frame.size.width - 60, 200)];
    [self.textView  setFont:[UIFont fontWithName: @"Trebuchet MS" size: 15.0f]];
    [self.textView setTextColor:[UIColor blackColor]];
    [self.textView  setBackgroundColor:[UIColor lightGrayColor]];
    [commentViewController.view addSubview: self.textView];
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeSystem];
    [button setFrame: CGRectMake(frame.size.width - 65, 25, 30, 200)];
    [button setTitle:@"Post" forState: UIControlStateNormal];
    [button setTitleColor: [UIColor blueColor] forState: UIControlStateNormal];
    [button addTarget:self action:@selector(postButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [self.view addSubview:button];
    [commentViewController.view addSubview: button];
    
    [self presentViewController: commentViewController animated: YES completion: nil];
}

-(void) postButtonClicked:(UIButton*)sender{
    NSNumber *commentCount = [self.post objectForKey: @"commentCount"];
    [self.comments addObject: self.textView.text];
    self.post.commentArray = self.comments;
    self.post.commentCount = [NSNumber numberWithInt: commentCount.intValue + 1];
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
           if (succeeded) {
               NSLog(@"Updated comments");
               [self dismissViewControllerAnimated: YES completion: nil];
               [self fetchComments];
           }
           else {
               NSLog(@"Failed to comment");
           }
       }];
}

- (IBAction)viewComments:(id)sender {
    [UIView animateWithDuration: 0.5 animations:^{
        CGRect newFrame = self.commentsView.frame;
        CGFloat y = self.usernameLabel.frame.origin.y;
        newFrame.origin.y = y;
        
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
            self.commentsView.frame = self.previousCommentFrame;
            self.tableView.frame = self.previousTableFrame;
        }
    }];
}

- (IBAction)backButton:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"AuthenticatedViewController"];
    myDelegate.window.rootViewController = navigationController;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CommentCell" forIndexPath: indexPath];
    cell.commentLabel.text = self.comments[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString: @"profileSegue"]){
          UINavigationController *navigationController = [segue destinationViewController];
        UsersProfileViewController *profileController = (UsersProfileViewController *)  navigationController.topViewController;
        profileController.post = self.post;
        profileController.type = NO;
    }
}

@end
